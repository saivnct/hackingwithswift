//
//  ActionViewController.swift
//  Extension
//
//  Created by Giang Bb on 7/5/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var script: UITextView!
    
    var pageTitle = "";
    var pageUrl = "";
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //When our extension is created, its extensionContext lets us control how it interacts with the parent app. In the case of inputItems this will be an array of data the parent app is sending to our extension to use. We only care about this first item in this project, and even then it might not exist, so we conditionally typecast using if let and as?
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider { //Our input item contains an array of attachments, which are given to us wrapped up as an NSItemProvider. Our code pulls out the first attachment from the first input item.
                
                //The next line uses loadItem(forTypeIdentifier: ) to ask the item provider to actually provide us with its item, but you'll notice it uses a closure so this code executes asynchronously. That is, the method will carry on executing while the item provider is busy loading and sending us its data
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String){ [unowned self] (dict, error) in    //Inside our closure we first need the usual [unowned self] to avoid strong reference cycles, but we also need to accept two parameters: the dictionary that was given to us to by the item provider, and any error that occurred.
                    let itemDictionary = dict as! NSDictionary
                    let javascriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary //the data we sent from JavaScript stored in a special key called NSExtensionJavaScriptPreprocessingResultsKey. So, we pull that value out from the dictionary, and put it into a value called javaScriptValues
                    print(javascriptValues) //We sent a dictionary of data from JavaScript, so we typecast javaScriptValues as an NSDictionary again so that we can pull out values using keys
                    
                    self.pageTitle = javascriptValues.value(forKey: "title") as! String
                    self.pageUrl = javascriptValues.value(forKey: "URL") as! String
                    
                    
                    //uses async() to set the view controller's title property on the main queue. This is needed because the closure being executed as a result of loadItem(forTypeIdentifier:) could be called on anything thread, and we don't want to change the UI unless we're on the main thread.
                    //You might have noticed that I haven't written [unowned self] in for the async() call, and that's because it's not needed. The closure will capture the variables it needs, which includes self, but we're already inside a closure that has declared self to be unowned, so this new closure will use that.
                    DispatchQueue.main.async {
                        self.title = self.pageTitle
                    }
                    
                }
            }
        }
        
        //The done() method was originally called as an action from the storyboard, but we deleted the navigation bar Apple put in because it's terrible. Instead, let's create a UIBarButtonItem in code, and make that call done() instead. Put this in viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        //Calling completeRequest(returningItems:) on our extension context will cause the extension to be closed, returning back to the parent app. However, it will pass back to the parent app any items that we specify, which in the current code is the same items that were sent in.
        //In a Safari extension like ours, the data we return here will be passed in to the finalize() function in the Action.js JavaScript file, so we're going to modify the done() method so that it passes back the text the user entered into our text view.
        //To make this work, we need to:
//        Create a new NSExtensionItem object that will host our items.
//        Create a dictionary containing the key "customJavaScript" and the value of our script.
//        Put that dictionary into another dictionary with the key NSExtensionJavaScriptFinalizeArgumentKey.
//        Wrap the big dictionary inside an NSItemProvider object with the type identifier kUTTypePropertyList.
//        Place that NSItemProvider into our NSExtensionItem as its attachments.
//        Call completeRequest(returningItems:), returning our NSExtensionItem.
        
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        extensionContext!.completeRequest(returningItems: [item])
        
        
        
        //We can ask to be told when the keyboard state changes by using a new class called NotificationCenter. Behind the scenes, iOS is constantly sending out notifications when things happen – keyboard changing, application moving to the background, as well as any custom events that applications post. We can add ourselves as an observer for certain notifications and a method we name will be called when the notification occurs, and will even be passed any useful information.
        //When working with the keyboard, the notifications we care about are UIKeyboardWillHide and UIKeyboardWillChangeFrame. The first will be sent when the keyboard has finished hiding, and the second will be shown when any keyboard state change happens – including showing and hiding, but also orientation, QuickType and more.
        //It might sound like we don't need UIKeyboardWillHide if we have UIKeyboardWillChangeFrame, but in my testing just using UIKeyboardWillChangeFrame isn't enough to catch a hardware keyboard being connected. Now, that's an extremely rare case, but we might as well be sure!
        //To register ourselves as an observer for a notification, we get a reference to the default notification center. We then use the addObserver() method, which takes four parameters: the object that should receive notifications (it's self), the method that should be called, the notification we want to receive, and the object we want to watch. We're going to pass nil to the last parameter, meaning "we don't care who sends the notification."
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyBoard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyBoard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
    }
    
    func adjustForKeyBoard(notification: Notification) {
        //The adjustForKeyboard() method is complicated, but that's because it has quite a bit of work to do. First, it will receive a parameter that is of type Notification. This will include the name of the notification as well as a Dictionary containing notification-specific information called userInfo.
        let userInfo = notification.userInfo!
        
        
        //When working with keyboards, the dictionary will contain a key called UIKeyboardFrameEndUserInfoKey telling us the frame of the keyboard after it has finished animating. This will be of type NSValue, which in turn is of type CGRect. The CGRect struct holds both a CGPoint and a CGSize, so it can be used to describe a rectangle
        //One of the quirks of Objective-C was that arrays and dictionaries couldn't contain structures like CGRect, so Apple had a special class called NSValue that acted as a wrapper around structures so they could be put into dictionaries and arrays. That's what's happening here: we're getting an NSValue object, but we know it contains a CGRect inside so we use its cgRectValue property to read that value.
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        //Once we finally pull out the correct frame of the keyboard, we need to convert the rectangle to our view's co-ordinates. This is because rotation isn't factored into the frame, so if the user is in landscape we'll have the width and height flipped – using the convert() method will fix that.
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            script.contentInset = UIEdgeInsets.zero
        }else{
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
        
        //setting the inset of a text view is done using the UIEdgeInsets struct, which needs insets for all four edges. I'm using the text view's content inset for its scrollIndicatorInsets to save time.
        
//        Note there's a check in there for UIKeyboardWillHide, and that's the workaround for hardware keyboards being connected by explicitly setting the insets to be zero.
    }
    
    
    //config in info.plist
    //NSExtensionActivationSupportsWebPageWithMaxCount - Adding this value to the dictionary means that we only want to receive web pages – we aren't interested in images or other data types.
    //"NSExtensionJavaScriptPreprocessingFile" - the value "Action" -  This tells iOS that when our extension is called, we need to run the JavaScript preprocessing file called Action.js, which will be in our app bundle. Make sure you type "Action" and not "Action.js", because iOS will append the ".js" itself.

}
