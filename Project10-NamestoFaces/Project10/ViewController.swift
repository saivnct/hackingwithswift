//
//  ViewController.swift
//  Project10
//
//  Created by Giang Bui Binh on 6/29/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit


//tells Swift you promise your class supports all the functionality required by the two protocols UIImagePickerControllerDelegate and UINavigationControllerDelegate. The first of those protocols is useful, telling us when the user either selected a picture or cancelled the picker. The second, UINavigationControllerDelegate, really is quite pointless here, so don't worry about it beyond just modifying your class declaration to include the protocol.
class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }
    
    @objc func addNewPerson() {
//import pictures using UIImagePickerController. This new class is designed to let users select an image from their camera to import into an app. When you first create a UIImagePickerController, iOS will automatically ask the user whether the app can access their photos.
//        when you want to read from user photos, you need to ask for permission first. This is a common theme in iOS, and is something you’ll face in other tasks too – reading the location, using the microphone, etc, all require explicit user permission.
        
//        To request permission for photos access you need to add a description of why you want access – what do you intend to do with their photos? Look for the file Info.plist in the project navigator and select it. This opens a new editor for modifying property list values (“plists”) – app configuration settings -> add new "privacy - photo library usage description"
        let picker = UIImagePickerController()
        picker.allowsEditing = true     //allows the user to crop the picture they select
        picker.delegate = self      //when you set self as the delegate, you'll need to conform not only to the UIImagePickerControllerDelegate protocol, but also the UINavigationControllerDelegate protocol
        picker.sourceType = .camera //source photo from camera
        present(picker, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - implement UIImagePickerControllerDelegate
    
    //when user finish pick a picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        let imgName = UUID().uuidString
        let imgPath = getDocumentDirectory().appendingPathComponent(imgName) // All apps that are installed have a directory called Documents where you can save private information for the app, and it's also automatically synchronized with iCloud
        
        if let jpegData = UIImageJPEGRepresentation(image, 80){ //onvert the UIImage to an Data object so it can be saved. To do that, we use the UIImageJPEGRepresentation() function, which takes two parameters: the UIImage to convert to JPEG and a quality value between 0 and 100
            try? jpegData.write(to: imgPath)
        }
        
        let person = Person(name: "unknown", image: imgName)
        people.append(person)
        
        collectionView?.reloadData()
        
        dismiss(animated: true)
    }
    
    //MARK: - Utils
    // All apps that are installed have a directory called Documents where you can save private information for the app, and it's also automatically synchronized with iCloud
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //MARK: - Config Collection View
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //dequeueReusableCell(withReuseIdentifier:for:) This creates a collection view cell using the reuse identified we specified, in this case "Person" because that was what we typed into Interface Builder earlier. But just like table views, this method will automatically try to reuse collection view cells, so as soon as a cell scrolls out of view it can be recycled so that we don't have to keep creating new ones.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonalCell   //we need to typecast our collection view cell as a PersonCell because we'll soon want to access its imageView and name outlets
        let person = people[indexPath.row]
        
        cell.name.text = person.name
        
        let path = getDocumentDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.row]
        
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Save", style: .default) { [unowned self, ac] _ in
            let newName = ac.textFields![0]
            person.name = newName.text!
            
            self.collectionView?.reloadData()
            
        })
        
        present(ac, animated: true)
    }


}

