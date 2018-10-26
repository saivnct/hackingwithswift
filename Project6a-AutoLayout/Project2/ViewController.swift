//
//  ViewController.swift
//  Project2
//
//  Created by Giang Bb on 6/23/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    @IBOutlet weak var btn1: UIButton!
    
    @IBOutlet weak var btn2: UIButton!
    
    @IBOutlet weak var btn3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        btn1.layer.borderWidth = 1
        btn2.layer.borderWidth = 1
        btn3.layer.borderWidth = 1
        
        btn1.layer.borderColor = UIColor.lightGray.cgColor      //UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor
        btn2.layer.borderColor = UIColor.lightGray.cgColor
        btn3.layer.borderColor = UIColor.lightGray.cgColor
        
        
        
        countries.append("estonia")
        countries.append("france")
        countries.append("germany")
        countries.append("ireland")
        countries.append("italy")
        countries.append("monaco")
        countries.append("nigeria")
        countries.append("poland")
        countries.append("russia")
        countries.append("spain")
        countries.append("uk")
        countries.append("us")
        
        //another way to fill array
//        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
       
        askQuestion(action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askQuestion(action: UIAlertAction!){
        //set random array by using GameplayKit Framework
        countries = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: countries) as! [String]
        btn1.setImage(UIImage(named: countries[0]), for: .normal);
        btn2.setImage(UIImage(named: countries[1]), for: .normal);
        btn3.setImage(UIImage(named: countries[2]), for: .normal);
        
        correctAnswer = GKRandomSource.sharedRandom().nextInt(upperBound: 3)  //get a random number from 0 to 2
        
        title = countries[correctAnswer].uppercased()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        if sender.tag == correctAnswer{
            title = "Right!"
            score+=1;
        }else{
            title = "Wrong!"
            score-=1;
        }
        
        let myText = "Your score is \(score)";
        
        let ac = UIAlertController(title: title, message: myText, preferredStyle: .alert);
        //In the case of UIAlertController(), there are two kinds of style: .alert, which pops up a message box over the center of the screen, and .actionSheet, which slides options up from the bottom. They are similar, but Apple recommends you use .alert when telling users about a situation change, and .actionSheet when asking them to choose from a set of options.
        
        ac.addAction(UIAlertAction(title: "Continute", style: .default, handler: askQuestion));
        //There are three possible styles: .default, .cancel, and .destructive. What these look like depends on iOS, but it's important you use them appropriately because they provide subtle user interface hints to users.
        //Warning: We must use askQuestion and not askQuestion(). If you use the former, it means "here's the name of the method to run," but if you use the latter it means "run the askQuestion() method now, and it will tell you the name of the method to run."
        
        
        //there's a problem, and Xcode is probably telling you what it is: “Cannot convert value of type ‘() -> ()’ to expected argument type ‘((UIAlertAction) -> Void)?’.” This is a good example of Swift's terrible error messages, and it's something I'm afraid you'll have to get used to. What it means to say is that using a method for this closure is fine, but Swift wants the method to accept a UIAlertAction parameter saying which UIAlertAction was tapped.
        
        
        
        present(ac, animated: true)
        
        
    }
    


}

