//
//  ViewController.swift
//  Project28
//
//  Created by Giang Bb on 7/29/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    
    @IBOutlet weak var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //We need to add the same code we used in project 16 to make the text view adjust its content and scroll insets when the keyboard appears and disappears.
        //We can ask to be told when the keyboard state changes by using a new class called NotificationCenter. Behind the scenes, iOS is constantly sending out notifications when things happen – keyboard changing, application moving to the background, as well as any custom events that applications post. We can add ourselves as an observer for certain notifications and a method we name will be called when the notification occurs, and will even be passed any useful information.
        //When working with the keyboard, the notifications we care about are UIKeyboardWillHide and UIKeyboardWillChangeFrame. The first will be sent when the keyboard has finished hiding, and the second will be shown when any keyboard state change happens – including showing and hiding, but also orientation, QuickType and more.
        //It might sound like we don't need UIKeyboardWillHide if we have UIKeyboardWillChangeFrame, but in my testing just using UIKeyboardWillChangeFrame isn't enough to catch a hardware keyboard being connected. Now, that's an extremely rare case, but we might as well be sure!
        //To register ourselves as an observer for a notification, we get a reference to the default notification center. We then use the addObserver() method, which takes four parameters: the object that should receive notifications (it's self), the method that should be called, the notification we want to receive, and the object we want to watch. We're going to pass nil to the last parameter, meaning "we don't care who sends the notification."
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
        
//        notification that will tell us when the application will stop being active – i.e., when our app has been backgrounded or the user has switched to multitasking mode
        notificationCenter.addObserver(self, selector: #selector(saveSecretMsg), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        title = "Nothing to see here"
        
    }
    
    func adjustForKeyboard(notification: Notification) {
        //The adjustForKeyboard() method is complicated, but that's because it has quite a bit of work to do. First, it will receive a parameter that is of type Notification. This will include the name of the notification as well as a Dictionary containing notification-specific information called userInfo.
        let userInfo = notification.userInfo!
        
        
        //When working with keyboards, the dictionary will contain a key called UIKeyboardFrameEndUserInfoKey telling us the frame of the keyboard after it has finished animating. This will be of type NSValue, which in turn is of type CGRect. The CGRect struct holds both a CGPoint and a CGSize, so it can be used to describe a rectangle
        //One of the quirks of Objective-C was that arrays and dictionaries couldn't contain structures like CGRect, so Apple had a special class called NSValue that acted as a wrapper around structures so they could be put into dictionaries and arrays. That's what's happening here: we're getting an NSValue object, but we know it contains a CGRect inside so we use its cgRectValue property to read that value.
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         //Once we finally pull out the correct frame of the keyboard, we need to convert the rectangle to our view's co-ordinates. This is because rotation isn't factored into the frame, so if the user is in landscape we'll have the width and height flipped – using the convert() method will fix that.
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        
        //cau hinh lai vung nhap lieu
        if notification.name == NSNotification.Name.UIKeyboardWillHide{
            secret.contentInset = UIEdgeInsets.zero
        }else{
            //canh duoi cua vung nhap bang chieu cao cua keyboard
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func authenticateTapped(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){  //Check whether the device is capable of supporting biometric authentication.
            let reason = "Identify yourself"
            
            // request that the Touch ID begin a check now, giving it a string containing the reason why we're asking.
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] (success, authenticationError)in
                DispatchQueue.main.async {
                    if success {
                        self.unlockSecretMsg()
                    }else{
                        //there are error cases you need to catch. For example, you’ll hit problems if the device does not have Touch ID capability or configured. This is true for all iPads before iPad Air 2 and iPad Mini 3, and all iPhones before the iPhone 5s. Similarly, you’ll get an error if the user failed Touch ID authentication. This might be because their print wasn't scanning for whatever reason, but also if the system has to cancel scanning for some reason
                        
                        let ac = UIAlertController(title: "Authentication failed", message: "Your fingerprint could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                        
                    }
                }
            }
            
        }else{      //no Touch ID
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        
        }
        
    }
    
    //The first of our two new methods, unlockSecretMessage(), needs to show the text view, then load the keychain's text into it. Loading strings from the keychain using KeychainWrapper is as simple as using its string(forKey:) method, but the result is optional so you should unwrap it once you know there's a value there.
    func unlockSecretMsg() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        if let text = KeychainWrapper.standardKeychainAccess().string(forKey: "SecretMessage")
        {
            secret.text = text
        }
    }
    
    func saveSecretMsg() {
        if (!secret.isHidden){
            _ = KeychainWrapper.standardKeychainAccess().setString(secret.text, forKey: "SecretMessage")
            secret.resignFirstResponder()   //tell our text view that we're finished editing it, so the keyboard can be hidden
            secret.isHidden = true
            title = "Nothing to see here"
        }
    }


}

