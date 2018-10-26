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
        // NOTE: it's never OK to do user interface work on the background thread.!!!!!!!!
        
        let urlString: String
        
        
        //the first instance of ViewController loads the original JSON, and the second loads only petitions that have at least 10,000 signatures.
        if navigationController?.tabBarItem.tag == 0{
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        }else{
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        //MARK: - USING GRAND CENTRAL DISPATCH GCD
        //We're going to use async() twice: once to push some code to a background thread, then once more to push code back to the main thread
        //GCD creates for you a number of queues, and places tasks in those queues depending on how important you say they are. All are FIFO, meaning that each block of code will be taken off the queue in the order they were put in, but more than one code block can be executed at the same time so the finish order isn't guaranteed
        //"How important" some code is depends on something called "quality of service", or QoS, which decides what level of service this code should be given. Obviously at the top of this is the main queue, which runs on your main thread, and should be used to schedule any work that must update the user interface immediately even when that means blocking your program from doing anything else. But there are four background queues that you can use, each of which has their own QoS level set:
                //User Interactive: this is the highest priority background thread, and should be used when you want a background thread to do work that is important to keep your user interface working. This priority will ask the system to dedicate nearly all available CPU time to you to get the job done as quickly as possible.
                //User Initiated: this should be used to execute tasks requested by the user that they are now waiting for in order to continue using your app. It's not as important as user interactive work – i.e., if the user taps on buttons to do other stuff, that should be executed first – but it is important because you're keeping the user waiting.
                //The Utility queue: this should be used for long-running tasks that the user is aware of, but not necessarily desperate for now. If the user has requested something and can happily leave it running while they do something else with your app, you should use Utility.
                //The Background queue: this is for long-running tasks that the user isn't actively aware of, or at least doesn't care about its progress or when it completes.
        //we're going to use async() to make all our loading code run in the background queue with default quality of service
        DispatchQueue.global().async { [unowned self] in
//            If you wanted to specify the user-initiated quality of service rather than use the default queue
//            DispatchQueue.global(qos: .userInitiated).async
            
            //We use if let to make sure the URL is valid, rather than force unwrapping it. Later on you can return to this to add more URLs, so it's good play it safe
            if let url = URL(string: urlString) {
                //We create a new Data object using its contentsOf method. This returns the content from an URL, but it might throw an error (i.e., if the internet connection was down) so we need to use try?
                if let data = try? Data(contentsOf: url) {
                    //If the Data object was created successfully, we create a new JSON object from it. This is a SwiftyJSON lib
                    let json = JSON(data: data)
                    if json["metadata"]["responseInfo"]["status"].intValue == 200 {
                        //respone OK from service
                        self.parse(json: json)
                        return
                    }
                }
            }
            
            self.showError()
        }
        
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
        for result in json["results"].arrayValue{
            let title = result["title"].stringValue
            let body = result["body"].stringValue
            let sigscount = result["signatureCount"].stringValue   //The signature count is actually a number when it comes in the JSON, but SwiftyJSON converts it for us so we can put it inside our dictionary where all the keys and values are string
            let obj = ["title": title, "body": body, "sigscount": sigscount]
            petitions.append(obj)
        }
        
        //Back to the main thread
        DispatchQueue.main.async { [unowned self] in
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: - process error
    func showError() {
        DispatchQueue.main.async { [unowned self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
        
    }


}

