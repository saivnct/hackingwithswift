//
//  ViewController.swift
//  Project32
//
//  Created by Giang Bui Binh on 10/9/17.
//  Copyright © 2017 giangbb. All rights reserved.
//
//When a user taps on one of our table rows, we want to show the Hacking with Swift project that matches their selection. In Ye Olden Days we would do this either with UIWebView or WKWebView, adding our own user interface to handle navigation. But this had a few problems: everyone's user interface was different, features such as cookies and Auto Fill were unavailable for security reasons, and inevitably users looked for an "Open in Safari" button because that was what they trusted.
///Apple fixed all these problems in iOS 9 using a new class called SFSafariViewController, which effectively embeds all of Safari inside your app using an opaque view controller. That is, you can't style it, you can't interact with it, and you certainly can't pull any private data out of it, and as a result SFSafariViewController can take advantage of the user's secure web data in ways that UIWebView and WKWebView never could.
//What's more, Apple builds powerful features right into SFSafariViewController, so you get things like content blocking free of charge – and users get consistent features, consistent UI, and consistent security. Everybody wins!
//SFSafariViewController is not part of UIKit, so you need to import a new framework to use it. Add this to the existing import UIKit line at the top of ViewController.swift:
import SafariServices

//Using Core Spotlight means importing two extra frameworks: CoreSpotlight and MobileCoreServices. The former does all the heavy lifting of indexing items; the latter is just there to identify what type of data we want to store.
import CoreSpotlight
import MobileCoreServices


import UIKit

class ViewController: UITableViewController {
    var projects = [[String]]()
    
    var favorites = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        projects.append(["Project 1: Storm Viewer", "Constants and variables, UITableView, UIImageView, FileManager, storyboards"])
        projects.append(["Project 2: Guess the Flag", "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController"])
        projects.append(["Project 3: Social Media", "UIBarButtonItem, UIActivityViewController, the Social framework, URL"])
        projects.append(["Project 4: Easy Browser", "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing"])
        projects.append(["Project 5: Word Scramble", "Closures, method return values, booleans, NSRange"])
        projects.append(["Project 6: Auto Layout", "Get to grips with Auto Layout using practical examples and code"])
        projects.append(["Project 7: Whitehouse Petitions", "JSON, Data, UITabBarController"])
        projects.append(["Project 8: 7 Swifty Words", "addTarget(), enumerated(), count, index(of:), property observers, range operators."])
        
        let defaults = UserDefaults.standard
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: project[0], subtitle: project[1])
        
        //To make our project titles and subtitles fully visible, we just need to tell the UITableViewCell that its label should show more than one line. Go back to Main.storyboard, then use the document outline to select the “Title” label inside the table view cell – you'll know when you have the correct thing selected because the Attributes inspector will say Label at the top.
        
//        Once the label is selected, look for the Lines property – it will be 1 by default, but you should change that to 0, which means "as many lines as it takes to fit the text."
        
        
        if favorites.contains(indexPath.row){
            cell.editingAccessoryType = .checkmark
        }else{
            cell.editingAccessoryType = .none
        }
        
        return cell        
    }
    
    //Now it's just a matter of telling the table view that some rows should have the "insert" icon and others the "delete" icon. To do that, you just need to implement the editingStyleForRowAt method and check whether the item in question is in the favorites array. Put this into your class:
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if favorites.contains(indexPath.row){
            return .delete
        }else{
            return .insert
        }
        //If you run the app now all the rows will have a green + symbol to their left and no checkmark on the right, because no projects have been marked as a favorite. If you click the + nothing will happen, because we haven't told the app what to do in that situation. To make this work, we need to handle the tableView(_:commit:forRowAt:) method, checking whether the user is trying to insert or delete their favorite.
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //If the user is adding a favorite, we're going to call a method called index(item:) that we'll write in a moment. We'll also add it to the favorites array, save it to UserDefaults then reload the table to reflect the change. If they are deleting a favorite, we do pretty much the opposite: call deindex(item:) (also not yet written), remove it from the favorites array, save that array and reload the table.
        if editingStyle == .insert {
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        }else{
            if let index = favorites.index(of: indexPath.row) {
                favorites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // we're going to make the project titles big and their subtitles small. We could do this by creating a UIFont at various sizes, but a much smarter (and user friendly!) way is to use a technology called Dynamic Type. This lets users control font size across all applications to match their preferences – they just make their choice in Settings, and Dynamic Type-aware apps respect it.
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        //Apple pre-defined a set of fonts for use with Dynamic Type, all highly optimized for readability, and all responsive to a user's settings. To use them, all you need to do is use the preferredFont(forTextStyle:) method of UIFont and tell it what style you want. In our case we're going to use .headline for the project title and .subheadline for the project subtitle.
        //Remarkably enough, that's all you need to handle Dynamic Type in this project, so we can turn to look at NSAttributedString. Like I said, this class is designed to show text with formatting, and you can use it all across iOS to show formatted labels, buttons, navigation bar titles, and more. You create an attributed string by giving it a plain text string plus a dictionary of the attributes you want to set. If you want finer-grained control you can provide specific ranges for formatting, e.g. "bold and underline the first 10 characters, then underline everything else."
        
        let titleAtributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedStringKey.foregroundColor: UIColor.purple]
        let subtitleAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAtributes)
        let subtitleString = NSMutableAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    func showTutorial(_ which: Int) {
        //When working with SFSafariViewController there are two things you need to know. First, you can either create it just with a URL or with a URL and some configuration settings. For example, you can enable reader mode if it’s available (Apple's name for a text-only view of web pages), or disable the bar collapsing behavior when the user scrolls. Reader mode doesn't work on Hacking with Swift, but I'm including it here so you can see how it works.
        //Second, the SFSafariViewController is dismissed when a user taps a Done button in its user interface. This calls a safariViewControllerDidFinish() method on the delegate of the SFSafariViewController, which you can use to run any code to handle picking up where the user left off. We won't be using it here, but if you want it in your own projects make sure you conform to the SFSafariViewControllerDelegate protocol.
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which+1)") {
            //this only work on ios 11
//            let config = SFSafariViewController.Configuration()
//            config.entersReaderIfAvailable = true
//            let vc = SFSafariViewController(url: url, configuration: config)
            let vc = SFSafariViewController(url: url)
            
            present(vc, animated: true)
        }
    }
    
    //Add - Remove item to/from CORE SPOTLIGHT
    func index(item: Int) {
        
//        Now for the new stuff: index(item:) accepts an Int identifying which project has been favorited. It needs to look inside the projects array to find that project, then create a CSSearchableItemAttributeSet object from it. This attribute set can store lots of information for search, including a title, description and image, as well as use-specific information such as dates (for events), camera focal length and flash setting (for photos), latitude and longitude (for places), and much more.
        
//        Regardless of what you choose, you wrap up the attribute set inside a CSSearchableItem object, which contains a unique identifier and a domain identifier. The former must identify the item absolutely uniquely inside your app, but the latter is a way to group items together. Grouping items is how you get to say "delete all indexed items from group X" if you choose to, but in our case we'll just use "com.hackingwithswift" because we don't need grouping. As for the unique identifier, we can use the project number.
        
//        To index an item, you need to call indexSearchableItems() on the default searchable index of CSSearchableIndex, passing in an array of CSSearchableItem objects. This method runs asynchronously, so we're going to use a trailing closure to be told whether the indexing was successful or not.
        let project = projects[item]
        
        let atributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)  //kUTTypeText as String, which tells iOS we want to store text in our indexed record.
        atributeSet.title = project[0]
        atributeSet.contentDescription = project[1]
        
        let itemSearch = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "giangbb.Project32", attributeSet: atributeSet)
        //By default, content you index has an expiration date of one month after you add it. This is probably OK for most purposes (although you do need to make sure you re-index items when your app runs in case they have expired!), but you can change the expiration date if you want. It's not something that can easily be tested, but this kind of code probably works to make your items never expire:
        itemSearch.expirationDate = Date.distantFuture
        
        CSSearchableIndex.default().indexSearchableItems([itemSearch]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func deindex(item: Int)  {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { error in
            if let error = error {
                print("Deindex error: \(error.localizedDescription)")
            }else{
                print("Deindex successfully")
            }
        }
    }
    //Now that we are indexing our content in Spotlight, users can search for our projects and tap on results. This will launch our app and pass in the unique identifier of the item that was tapped, and it's down to the app to do something with it. This is all done using in an AppDelegate.swift method called application(_:continue:restorationHandler:), with the important part being what's given to us as the continue parameter.
    //This app delegate method is called when the application has finished launching and it's time to launch the activity requested by the user. If the user activity has the type CSSearchableItemActionType it means we're being launched as a result of a Spotlight search, so we need to unwrap the value of the CSSearchableItemActivityIdentifier that was passed in – that's the unique identifier of the indexed item that was tapped. In this project, that's the project number.
    //Once we know which project caused the app to be launched, we need to do a little view controller dance that involves conditionally typecasting the window’s root view controller as a UINavigationController, then conditionally typecasting its topViewController as a ViewController object, and finally calling the showTutorial() method on the result if it succeeded.


}

