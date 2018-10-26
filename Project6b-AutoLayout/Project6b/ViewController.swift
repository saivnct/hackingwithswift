//
//  ViewController.swift
//  Project6b
//
//  Created by Giang Bui Binh on 6/27/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //tells iOS we don't want to show the iOS status bar on this view controller
    override var prefersStatusBarHidden: Bool{
        return true
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //set the property translatesAutoresizingMaskIntoConstraints to be false on each label, because by default iOS generates Auto Layout constraints for you based on a view's size and position. We'll be doing it by hand, so we need to disable this feature
        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.backgroundColor = UIColor.red
        label1.text = "THESE"
        
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.backgroundColor = UIColor.cyan
        label2.text = "ARE"
        
        let label3 = UILabel()
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.backgroundColor = UIColor.yellow
        label3.text = "SOME"
        
        let label4 = UILabel()
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.backgroundColor = UIColor.green
        label4.text = "AWESOME"
        
        let label5 = UILabel()
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.backgroundColor = UIColor.orange
        label5.text = "LABELS"
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)
        
        //MARK: - using FVL
        //using a technique called Auto Layout Visual Format Language (VFL), which is kind of like a way of drawing the layout you want with a series of keyboard symbols
        
//        let viewsDictionary = [
//            "label1": label1,
//            "label2": label2,
//            "label3": label3,
//            "label4": label4,
//            "label5": label5
//        ]
        
        //That's the entire VFL line explained: each of our labels should stretch edge-to-edge in our view
//        for label in viewsDictionary.keys {
//            //view.addConstraints(): this adds an array of constraints to our view controller's view. This array is used rather than a single constraint because VFL can generate multiple constraints at a time.
//            //NSLayoutConstraint.constraints(withVisualFormat:) is the Auto Layout method that converts VFL into an array of constraints. It accepts lots of parameters, but the important ones are the first and last
//            //We pass [] (an empty array) for the options parameter and nil for the metrics parameter. You can use these options to customize the meaning of the VFL, but for now we don't care.
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: viewsDictionary))
//
//            //The H: parts means that we're defining a horizontal layout; we'll do a vertical layout soon. The pipe symbol, |, means "the edge of the view." We're adding these constraints to the main view inside our view controller, so this effectively means "the edge of the view controller." Finally, we have [label1], which is a visual way of saying "put label1 here"
//
//            //So, "H:|[label1]|" means "horizontally, I want my label1 to go edge to edge in my view." But there's a hiccup: what is "label1"? Sure, we know what it is because it's the name of our variable, but variable names are just things for humans to read and write – the variable names aren't actually saved and used when the program runs.
//            //This is where our viewsDictionary dictionary comes in: we used strings for the key and UILabels for the value, then set "label1" to be our label. This dictionary gets passed in along with the VFL, and gets used by iOS to look up the names from the VFL. So when it sees [label1], it looks in our dictionary for the "label1" key and uses its value to generate the Auto Layout constraints
//        }
        
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1]-[label2]-[label3]-[label4]-[label5]", options: [], metrics: nil, views: viewsDictionary))
//        //this time we're specifying V:, meaning that these constraints are vertical. And we have multiple views inside the VFL, so lots of constraints will be generated. The new thing in the VFL this time is the - symbol, which means "space". It's 10 points by default, but you can customize it.
        
        //add a constraint for the bottom edge saying that the bottom of our last label must be at least 10 points away from the bottom of the view controller's view. We're also going to tell Auto Layout that we want each of the five labels to be 88 points high
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(==88)]-[label2(==88)]-[label3(==88)]-[label4(==88)]-[label5(==88)]-(>=10)-|", options: [], metrics: nil, views: viewsDictionary))
//        //The difference here is that we now have numbers inside parentheses: (==88) for the labels, and (>=10) for the space to the bottom. Note that when specifying the size of a space, you need to use the - before and after the size: a simple space, -, becomes -(>=10)-.
//        
//        
//        //you can give VFL a set of sizes with names, then use those sizes in the VFL rather than hard-coding numbers. For example, we wanted our label height to be 88, so we could create a metrics dictionary like this:
//        let metrics = ["labelHeight": 88]
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight)]-[label2(labelHeight)]-[label3(labelHeight)]-[label4(labelHeight)]-[label5(labelHeight)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))
//
//        
//
//        //Constraint priority '@' is a value between 1 and 1000, where 1000 means "this is absolutely required" and anything less is optional. By default, all constraints you have are priority 1000, so Auto Layout will fail to find a solution in our current layout. But if we make the height optional – even as high as priority 999 – it means Auto Layout can find a solution to our layout: shrink the labels to make them fit
        //So, we're going to make the label height have priority 999 (i.e., very important, but not required). But we're also going to make one other change, which is to tell Auto Layout that we want all the labels to have the same height. This is important, because if all of them have optional heights using labelHeight, Auto Layout might solve the layout by shrinking one label and making another 88.
        //we're going to make the first label use labelHeight at a priority of 999, then have the other labels adopt the same height as the first label
//         view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|", options: [], metrics: metrics, views: viewsDictionary))
        
        
        
        //MARK: - using Anchor
        
        //Every UIView has a set of anchors that define its layouts rules. The most important ones are widthAnchor, heightAnchor, topAnchor, bottomAnchor, leftAnchor, rightAnchor, leadingAnchor, trailingAnchor, centerXAnchor, and centerYAnchor.
        //Most of those should be self-explanatory, but it’s worth clarifying the difference between leftAnchor, rightAnchor, leadingAnchor, and trailingAnchor. For me, left and leading are the same, and right and trailing are the same too.
        var previous: UILabel!
        for label in [label1,label2,label3,label4,label5] {
            label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            //we have previous label - create a height constraint
            if previous != nil
            {
                //the top anchor for each label to be equal to the bottom anchor of the previous label in the loop
//                label.topAnchor.constraint(equalTo: previous.bottomAnchor).isActive = true
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
                label.heightAnchor.constraint(equalTo: previous.heightAnchor).isActive = true
            }else{  //for the first label
                //        label.heightAnchor.constraint(equalToConstant: 88).isActive = true
                label.heightAnchor.constraint(lessThanOrEqualToConstant: 88)
                label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
            previous = label
        }

        label5.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor).isActive = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

