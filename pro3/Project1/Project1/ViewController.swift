//
//  ViewController.swift
//  Project1
//
//  Created by Giang Bb on 10/19/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    //String] means “an array of strings”, and () means “create one now.”
    var pictures = [String]()
    
    //called when the screen has loaded, and is ready for you to customize
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Storm Viewer"
        
       
        
        //Large titles in iOS 11
        //Apple recommends you use large titles only when it makes sense, and that usually means only on the first screen of your app
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let fm=FileManager.default
        let path = Bundle.main.resourcePath!
        //try! keyword means “the following code has the potential to go wrong, but I’m absolutely certain it won’t.” If the code does fail – for example if the directory we asked for doesn’t exist – our app will crash.
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl"){
                pictures.append(item)
            }
        }
        print(pictures)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //To save CPU time and RAM, iOS only creates as many rows as it needs to work. When one rows moves off the top of the screen, iOS will take it away and put it into a reuse queue ready to be recycled into a new row that comes in from the bottom. This means you can scroll through hundreds of rows a second, and iOS can behave lazily and avoid creating any new table view cells – it just recycles the existing ones
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        cell.textLabel?.text = pictures[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1: try loading the "Detail" view controller and typecasting it to be DetailViewController
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            // 2: success! Set its selectedImage property
            vc.selectedImg = pictures[indexPath.row]
            // 3: now push it onto the navigation controller
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

