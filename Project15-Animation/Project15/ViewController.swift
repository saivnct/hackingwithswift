//
//  ViewController.swift
//  Project15
//
//  Created by Giang Bui Binh on 7/4/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tap: UIButton!
    
    var imageView: UIImageView!
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapped(_ sender: UIButton) {
        tap.isHidden = true
        
        //This switch/case statement is going to go inside a new method of the UIView class called animate(withDuration:), which is a kind of method you haven't seen before because it actually accepts two closures. The parameters we'll be using are how to long animate for, how long to pause before the animation starts, any options you want to provide, what animations to execute, and finally a closure that will execute when the animation finishes.
        //The parameters we'll be using are how to long animate for, how long to pause before the animation starts, any options you want to provide, what animations to execute, and finally a closure that will execute when the animation finishes
        //Because the completion closure is the final parameter to the method, we'll be using trailing closure syntax just like we did in project 5.
        UIView.animate(withDuration: 1, delay: 0,usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], //uses spring animations rather than the default, ease-in-ease-out animation //duration of 1 second, no delay, and no interesting options.
                       animations: { [unowned self] in  //we first do the usual [unowned self] in dance to avoid strong reference cycles
            //CGAffineTransform - is a structure that represents a specific kind of transform that we can apply to any UIView object or subclass
            //Unless you're into mathematics, affine transforms can seem like a black art. But Apple does provide some great helper functions to make it easier: there are functions to scale up a view, functions to rotate, functions to move, and functions to reset back to default.
            //All of these functions return a CGAffineTransform value that you can put into a view's transform property to apply it
            switch self.currentAnimation {
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2)   // we want to make the view 2x its default size
               break
            case 1:
                self.imageView.transform = CGAffineTransform.identity //CGAffineTransform.identity - This effectively clears our view of any pre-defined transform, resetting any changes that have been applied by modifying its transform property
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256) //uses another new initializer for CGAffineTransform that X and Y values for its parameters. These values are deltas, or differences from the current value, meaning that the above code subtracts 256 from both the current X and Y position.
            case 3:
                self.imageView.transform = CGAffineTransform.identity
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi) //rotationAngle initializer. This accepts one parameter, which is the amount in radians you want to rotate. There are three catches to using this function:
                //You need to provide the value in radians specified as a CGFloat. This usually isn't a problem – if you type 1.0 in there, Swift is smart enough to make that a CGFloat automatically. If you want to use a value like pi, use CGFloat.pi
                //Core Animation will always take the shortest route to make the rotation work. So, if your object is straight and you rotate to 90 degrees (radians: half of pi), it will rotate clockwise. If your object is straight and you rotate to 270 degrees (radians: pi + half of pi) it will rotate counter-clockwise because it's the smallest possible animation
                //A consequence of the second catch is that if you try to rotate 360 degrees (radians: pi times 2), Core Animation will calculate the shortest rotation to be "just don't move, because we're already there." The same goes for values over 360, for example if you try to rotate 540 degrees (one and a half full rotations), you'll end up with just a 180-degree rotation.
            case 5:
                self.imageView.transform = CGAffineTransform.identity
            case 6:
                //As well as animating transforms, Core Animation can animate many of the properties of your views. For example, it can animate the background color of the image view, or the level of transparency. You can even change multiple things at once if you want something more complicated to happen.
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = UIColor.green
                
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = UIColor.clear
            default:
                break
            }
        }){[unowned self] (finished: Bool) in   //We use trailing closure syntax to provide our completion closure
            self.tap.isHidden = false;
        }
        
        //NOTE:  if UIKit detects that no animation has taken place, it calls the completion closure straight away
        currentAnimation += 1
        if (currentAnimation>7) {
            currentAnimation = 0
        }
        
        
    }

}

