//
//  DetailViewController.swift
//  Project1
//
//  Created by Giang Bb on 10/19/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imgView: UIImageView!
    var selectedImg: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedImg
        
        //Large titles in iOS 11
        //Apple recommends you use large titles only when it makes sense, and that usually means only on the first screen of your app
         navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

        // Do any additional setup after loading the view.
        if let imgToLoad = selectedImg {
            imgView.image = UIImage(named: imgToLoad)
        }
    }
    
    //When you call a method using #selector you’ll always need to use @objc too
    @objc func shareTapped() {
        //creates a UIActivityViewController, which is the iOS method of sharing content with other apps and services
        //activityItems: an array of items you want to share, applicationActivities: an array of any of your own app's services you want to make sure are in the list
        let vc = UIActivityViewController(activityItems: [imgView.image!], applicationActivities: [])
        //tells iOS where the activity view controller should be anchored – where it should appear from
        //On iPhone, activity view controllers automatically take up the full screen, but on iPad they appear as a popover that allows the user to see what they were working on below. This line of code tells iOS to anchor the activity view controller to the right bar button item (our share button), but this only has an effect on iPad – on iPhone it's ignored
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc,animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide navidation bar when touch on screen
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnTap = false
    }
    
    //IPHONE X
    override var prefersHomeIndicatorAutoHidden: Bool {
        return navigationController?.hidesBarsOnTap ?? false
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
