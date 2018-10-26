//
//  ViewController.swift
//  Project18
//
//  Created by Giang Bb on 7/13/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //MARK: DEBUG WITH PRINT
        //print() - you can actually pass it lots of values at the same time, and it will print them al
        //This is known as a “variadic function” – a function that accepts any number of parameters
        //print()’s variadic nature becomes much more useful when you use its optional extra parameters: separator and terminator
        // separator, lets you provide a string that should be placed between every item in the print() call
        // terminator, is what should be placed after the final item. It’s \n by default
        print(1,2,3,4,5, separator: "-", terminator: "lineend")
        print(6, 7, 8, 9, 10, separator: "-")
        
        
        
        
        
        //MARK: DEBUG WITH ASSERT
        //ASSERT will force your app to crash if a specific condition isn't true
        //these assertion crashes only happen while you’re debugging. When you build a release version of your app – i.e., when you ship your app to the App Store – Xcode automatically disables your assertions so they won’t reach your users. This means you can set up an extremely strict environment while you’re developing, ensuring that all values are present and correct, without causing problems for real users
        assert(1 == 1, "Math 1==1 failed")
//        assert(2 == 1, "Math 2==1 failed")        //your app will be crashed here
        //In fact, because calls to assert() are ignored in release builds of your app, you can do complex checks:
        //That myReallySlowMethod() call will execute only while you’re running test builds – that code will be removed entirely when you build for the App Store.
//       assert(myReallySlowMethod() == false, "The slow method returned false, which is a bad thing!")
        
        
        
        //MARK: DEBUG WITH BREAKPOINT
        //F6
        //Ctrl+Cmd+Y
        //here’s one more neat trick that few people know about: that light green arrow that shows your current execution position can be moved. Just click and drag it somewhere else to have execution pick up from there – although Xcode will warn you that it might have unexpected results, so tread carefully!
        //Xcode also gives you an interactive LLDB debugger window, where you can type commands to query values and run methods. If it’s visible, you’ll see “(lldb)” in light blue at the bottom of your Xcode window. If you don’t see that, go to View > Debug Area > Activate Console, at which point focus will move to the LLDB window. Try typing p i to ask Xcode to print the value of the i variable.
        //you can make breakpoints conditional, meaning that they will pause execution of your program only if the condition is matched - Right-click on the breakpoint (the blue arrow marker) and choose Edit Breakpoint. In the popup that appears, set the condition value to be i % 10 == 0 – this uses modulo, as seen in project 8. With that in place, execution will now pause only when i is 10, 20, 30 and so on, up to 100
        for i in 1 ... 100{
            print("Got number \(i)")
        }
        
        //The second clever thing that breakpoints can do is be automatically triggered when an exception is thrown. Exceptions are errors that aren't handled, and will cause your code to crash. With breakpoints, you can say "pause execution as soon as an exception is thrown," so that you can examine your program state and see what the problem is.To make this happen, press Cmd+7 to choose the breakpoint navigator – it's on the left of your screen, where the project navigator normally sits. Now click the + button in the bottom-left corner and choose "Add Exception Breakpoint." That's it! The next time your code hits a fatal problem, the exception breakpoint will trigger and you can take action.
        
        
        
        ////MARK: DEBUG WITH VIEW DEBUGGING
        //View debugging used to be difficult to do, because you'd have a complicated view controller layout with buttons, labels, views inside views, and so on. If something wasn't showing, it was hard to know why.
        //Xcode can help you with two clever features. The first is called Show View Frames, and it's accessible under the Debug menu by choosing View Debugging > Show View Frames. If you have a complicated view layout (project 8 is a good example!), this option will draw lines around all your views so you can see exactly where they are.
        //The second feature is extraordinary, but I've only seen it used to good effect a couple of times. It's called Capture View Hierarchy, and when it's used your see your current view layout inside Xcode with thin gray lines around all the views. You might think this is just like Show View Frames, but it's cleverer than that! - If you click and drag inside the hierarchy display, you'll see you're actually viewing a 3D representation of your view, which means you can look behind the layers to see what else is there. The hierarchy automatically puts some depth between each of its views, so they appear to pop off the canvas as you rotate them. This debug mode is perfect for times when you know you've placed your view but for some reason can't see it – often you'll find the view is behind something else by accident.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

