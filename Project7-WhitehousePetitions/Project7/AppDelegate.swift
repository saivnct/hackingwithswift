//
//  AppDelegate.swift
//  Project7
//
//  Created by Giang Bui Binh on 6/27/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        //add new viewcontroller to tabcontroller by code
        //So, bellow code creates a duplicate ViewController wrapped inside a navigation controller, gives it a new tab bar item to distinguish it from the existing tab, then adds it to the list of visible tabs. This lets us use the same class for both tabs without having to duplicate things in the storyboard.
        
        
        //Our storyboard automatically creates a window in which all our view controllers are shown. This window needs to know what its initial view controller is, and that gets set to its rootViewController property. This is all handled by our storyboard.
        //In the Single View Application template, the root view controller is the ViewController, but we embedded ours inside a navigation controller, then embedded that inside a tab bar controller. So, for us the root view controller is a UITabBarController
        if let tabBarController = window?.rootViewController as? UITabBarController {
            
            //We need to create a new ViewController by hand, which first means getting a reference to our Main.storyboard file. This is done using the UIStoryboard class, as shown. You don't need to provide a bundle, because nil means "use my current app bundle."
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            //We create our view controller using the instantiateViewController() method, passing in the storyboard ID of the view controller we want. Earlier we set our navigation controller to have the storyboard ID of "NavController", so we pass that in
            let vc = storyboard.instantiateViewController(withIdentifier: "NavController")
            vc.tabBarItem = UITabBarItem(tabBarSystemItem: .topRated, tag: 1)
            tabBarController.viewControllers?.append(vc)
        }
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


}

