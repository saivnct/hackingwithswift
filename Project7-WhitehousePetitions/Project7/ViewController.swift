//
//  ViewController.swift
//  Project7
//
//  Created by Giang Bui Binh on 6/27/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [[String: String]]()  //an array of dictionary
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let urlString: String
        
        
        //WARNING: This code isn't perfect, in fact far from it. In fact, by downloading data from the internet in viewDidLoad() our app will lock up until all the data has been transferred. There are solutions to this, but to avoid complexity they won't be covered until project 9.
        
        
        //the first instance of ViewController loads the original JSON, and the second loads only petitions that have at least 10,000 signatures.
        if navigationController?.tabBarItem.tag == 0{
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        }else{
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        //We use if let to make sure the URL is valid, rather than force unwrapping it. Later on you can return to this to add more URLs, so it's good play it safe
        if let url = URL(string: urlString) {
            //We create a new String object using its contentsOf method. This returns the content from a URL, but it might throw an error (i.e., if the internet connection was down) so we need to use try?
            if let data = try? String(contentsOf: url) {
                //If the Data object was created successfully, we create a new JSON object from it. This is a SwiftyJSON lib
                let json = JSON(parseJSON: data)
                if json["metadata"]["responseInfo"]["status"].intValue == 200 {
                        //respone OK from service
                    self.parse(json: json)
                    return
                }
            }
        }
        
        self.showError()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - tableview config
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let obj = petitions[indexPath.row]
        
        cell.textLabel?.text = obj["title"]
        cell.detailTextLabel?.text = obj["body"]

        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Previously we used the instantiateViewController() method to load a view controller from Main.storyboard, but in this project DetailViewController isn’t in the storyboard – it’s just a free-floating class. This makes didSelectRowAt easier, because it can load the class directly rather than loading the user interface from a storyboard.
        
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - process JSON
    func parse(json: JSON) {
        for result in json["results"].arrayValue{ //When you use arrayValue with SwiftyJSON, you either get back an array of objects or an empty array
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigscount = result["signatureCount"].stringValue   //The signature count is actually a number when it comes in the JSON, but SwiftyJSON converts it for us so we can put it inside our dictionary where all the keys and values are string
            let obj = ["title": title, "body": body, "sigscount": sigscount]
            petitions.append(obj)
        }
        
        tableView.reloadData()
    }
    
    //MARK: - process error
    func showError() {
        let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }


}

