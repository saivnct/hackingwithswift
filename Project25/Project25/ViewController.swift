//
//  ViewController.swift
//  Project25
//
//  Created by Giang Bb on 7/27/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import MultipeerConnectivity

//Multipeer connectivity requires four new classes:
    //MCSession is the manager class that handles all multipeer connectivity for us.
    //MCPeerID identifies each user uniquely in a session.
    //MCAdvertiserAssistant is used when creating a session, telling others that we exist and handling invitations.
    //MCBrowserViewController is used when looking for sessions, showing users who is nearby and letting them join

//Most important of all is that all multipeer services on iOS must declare a service type, which is a 15-digit string that uniquely identify your service. Those 15 digits can contain only the letters A-Z, numbers and hyphens, and it's usually preferred to include your company in there somehow
    //Apple's example is, "a text chat app made by ABC company could use the service type abc-txtchat"; for this project I'll be using hws-project25.
    //This service type is used by both MCAdvertiserAssistant and MCBrowserViewController to make sure your users only see other users of the same app. They both also want a reference to your MCSession instance so they can take care of connections for you.
class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    var images = [UIImage]()
    
    var peerId: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Selfie Share"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        
        peerId = MCPeerID(displayName: UIDevice.current.name)   //we're creating an MCPeerID object using the name of the current device, which will usually be something like "Paul's iPhone"
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required) //That ID is then used to create the session, along with the encryption option of .required to ensure that any data transferred is kept safe
        mcSession.delegate = self
    }
    
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func showConnectionPrompt()  {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
        present(ac, animated: true)
    }
    
    //MARK: - UIAlertController handler
    func startHosting(action:UIAlertAction) {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    func joinSession(action:UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        
        present(mcBrowser, animated: true)
    }
    

    //MARK: - Implement UICollectionViewController
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    
    //MARK: - Implement UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else{
            return
        }
        
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView?.reloadData()
        
        //Sending images across a multipeer connection is remarkably easy. In project 10 you met the function UIImageJPEGRepresentation(), which converts a UIImage object into an Data so it can be saved to disk. Well, MCSession objects have a sendData() method that will ensure that data gets transmitted reliably to your peers.
        //1. Check if there are any peers to send to.
        //2. Convert the new image to an Data object.
        //3. Send it to all peers, ensuring it gets delivered.
        //4. Show an error message if there's a problem
        
        //1
        if mcSession.connectedPeers.count > 0{
            //2
            if let imageData = UIImagePNGRepresentation(image){
                //3
                //you've seen try! and try? before, but this time I'm using plain old try without a question or exclamation mark. This means "try running this code, and let me know if it fails."
                //To make this work, you need to surround your code in a do/catch block as shown above. When any error is thrown in the do block, your program immediately jumps straight to the catch block where you can handle it – or in our case show a message. Swift automatically creates an error constant telling you what went wrong
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)   //ensure data gets sent intact to all peers, as opposed to having some parts lost in the ether, is just to use transmission mode .reliable – nothing more.
                } catch  {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
        
    }
    
    //MARK: -Implement MCSessionDelegate
    
    //not important  method
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    //not important  method
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    //not important  method
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    
    //When a user connects or disconnects from our session, the method session(_:peer:didChangeState:) is called so you know what's changed – is someone connecting, are they now connected, or have they just disconnected? We're not going to be using this information in the project,
    //This is helpful for debugging, because it means you can look in Xcode's debug console to see these messages and know your code is working.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerId.displayName)")
            break
        case .connecting:
            print("Connecting: \(peerId.displayName)")
            break
        case .notConnected:
            print("Not Connected: \(peerId.displayName)")
            break
        }
    }
    
        
    //Once the data arrives at each peer, the method session(_:didReceive:fromPeer:) will get called with that data, at which point we can create a UIImage from it and add it to our images array. There is one catch: when you receive data it might not be on the main thread, and you never manipulate user interfaces anywhere but the main thread, right? Right
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [unowned self] in
                self.images.insert(image, at: 0)
                self.collectionView?.reloadData()
            }
        }
    }
    
    
    //MARK: -Implement MCBrowserViewControllerDelegate
    //The two methods we're going to implement that are trivial are both for the multipeer browser: one is called when it finishes successfully, and one when the user cancels. Both methods just need to dismiss the view controller that is currently being presented
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    
    
    
    

}

