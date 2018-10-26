//
//  ViewController.swift
//  Project21
//
//  Created by Giang Bb on 7/14/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(stopSchedule))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @objc func stopSchedule() {
//        let center = UNUserNotificationCenter.current()
//        center.removeAllPendingNotificationRequests()
//    }
    
    
    //in order to send local notifications in our app, we first need to request permission, and that's what we'll put in the registerLocal() method. You register your settings based on what you actually need, and that's done with a method called requestAuthorization() on UNUserNotificationCenter
    //For this example we're going to request an alert (a message to show), along with a badge (for our icon) and a sound (because users just love those.)
    //You also need to provide a closure that will be executed when the user has granted or denied your permissions request. This will be given two parameters: a boolean that will be true if permission was granted, and an Error? containing a message if something went wrong
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]){ (granted, error) in
            if granted {
                print("User grant permission to use NotificationCenter")
            }else{
                print("User reject request to use NotificationCenter")
            }
        }
    }

    @objc func scheduleLocal(){
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        
        //If you want to test out your notifications.
        //First, you can cancel pending notifications – i.e., notifications you have scheduled that have yet to be delivered because their trigger hasn’t been met
        center.removeAllPendingNotificationRequests()
        
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"    //You can also attach custom actions by specifying the categoryIdentifier property.
        content.userInfo = ["customData": "fizzbuzz"] //To attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property
        content.sound = UNNotificationSound.default()
        
        
        //the trigger – when to show the notification – can be a calendar trigger that shows the notification at an exact time, it can be an interval trigger that shows the notification after a certain time interval has lapsed, or it can be a geofence that shows the notification based on the user’s location
        
//        //calendar trigger
//        var dateComponents = DateComponents()
//        dateComponents.hour = 16
//        dateComponents.minute = 55
//        // if you specify hour 8 and minute 30, and don’t specify a day, it means either “8:30 tomorrow” or “8:30 every day” depending on whether you ask for the notification to be repeated
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true) //time interval must be at least 60 if repeating
        
        // each notification also has a unique identifier. This is just a string you create, but it does need to be unique because it lets you update or remove notifications programmatically
        //For this project we don’t care what name is used for each notification, but we do want it to be unique. So, we’ll be using the UUID class to generate unique identifiers
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more ...", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    //MARK: - implement UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String{
            print("Custom data recieved: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier: //gets sent when the user swiped on the notification to unlock their device and launch the app
                print("Default identifier")
                break
            case "show":    //click on show button
                  print("Show more information…")
                break
            default:
                break
            }
        }
        
        // you must call the completion handler when you're done
        completionHandler()
    }
    
    

}

