//
//  AppDelegate.swift
//  Project32
//
//  Created by Giang Bui Binh on 10/9/17.
//  Copyright © 2017 giangbb. All rights reserved.
//
//AppDelegate.swift doesn’t already import the CoreSpotlight framework, so if you rely on code completion (as you should!) add this import to AppDelegate.swift now:
import CoreSpotlight

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    ////This app delegate method is called when the application has finished launching and it's time to launch the activity requested by the user. If the user activity has the type CSSearchableItemActionType it means we're being launched as a result of a Spotlight search, so we need to unwrap the value of the CSSearchableItemActivityIdentifier that was passed in – that's the unique identifier of the indexed item that was tapped. In this project, that's the project number.
    //Once we know which project caused the app to be launched, we need to do a little view controller dance that involves conditionally typecasting the window’s root view controller as a UINavigationController, then conditionally typecasting its topViewController as a ViewController object, and finally calling the showTutorial() method on the result if it succeeded.
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if let navigationController = window?.rootViewController as? UINavigationController {
                    if let viewController = navigationController.topViewController as? ViewController {
                        viewController.showTutorial(Int(uniqueIdentifier)!)
                    }
                }
            }
        }
        
        return true
    }


}

