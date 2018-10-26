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
        
        //load app data
        loadAppData()
    }
    
    func addNewPerson() {
//import pictures using UIImagePickerController. This new class is designed to let users select an image from their camera to import into an app. When you first create a UIImagePickerController, iOS will automatically ask the user whether the app can access their photos.
//        when you want to read from user photos, you need to ask for permission first. This is a common theme in iOS, and is something you’ll face in other tasks too – reading the location, using the microphone, etc, all require explicit user permission.
        
//        To request permission for photos access you need to add a description of why you want access – what do you intend to do with their photos? Look for the file Info.plist in the project navigator and select it. This opens a new editor for modifying property list values (“plists”) – app configuration settings -> add new "privacy - photo library usage description"
        let picker = UIImagePickerController()
        picker.allowsEditing = true     //allows the user to crop the picture they select
        picker.delegate = self      //when you set self as the delegate, you'll need to conform not only to the UIImagePickerControllerDelegate protocol, but also the UINavigationControllerDelegate protocol
        present(picker, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - working with data
    ///You can use UserDefaults to store any basic data type for as long as the app is installed. You can write basic types such as Bool, Float, Double, Int, String, or URL, but you can also write more complex types such as arrays, dictionaries and Date – and even Data values
    //When you write data to UserDefaults, it automatically gets loaded when your app runs so that you can read it back again. This makes using it really easy, but you need to know that it's a bad idea to store lots of data in there because it will slow loading of your app. If you think your saved data would take up more than say 100KB, UserDefaults is almost certainly the wrong choice
    // If you want to save any user settings, or if you want to save program settings, it's just the best place for it
    //please don't consider UserDefaults to be safe, because it isn't. If you have user information that is private, you should consider writing to the keychain instead – something we'll look at in project 28
    func saveAppData() {
        let jsonEncoder = JSONEncoder()
        if let saveData = try? jsonEncoder.encode(people){
            let defaults = UserDefaults.standard
            defaults.set(saveData, forKey: "people")
        }else{
            print("Can not save people")
        }
    }
    
    func loadAppData() {
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            do{
                //[Person].self, which is Swift’s way of saying “attempt to create an array of Person objects. This is why we don’t need a typecast when assigning to people – that method will automatically return [People], or if the conversion fails then the catch block will be executed instead
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            }catch{
                print("Can not load people")
            }
            
        }
    }
    
    
    //MARK: - implement UIImagePickerControllerDelegate
    //when user finish pick a picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            return
        }
        
        let imgName = UUID().uuidString
        let imgPath = getDocumentDirectory().appendingPathComponent(imgName)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80){ //onvert the UIImage to an Data object so it can be saved. To do that, we use the UIImageJPEGRepresentation() function, which takes two parameters: the UIImage to convert to JPEG and a quality value between 0 and 100
            try? jpegData.write(to: imgPath)
        }
        
        let person = Person(name: "unknown", image: imgName)
        people.append(person)
        
        collectionView?.reloadData()
        saveAppData()
        dismiss(animated: true)
    }
    
    //MARK: - Utils
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonalCell
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
            self.saveAppData()
        })
        
        present(ac, animated: true)
    }


}

