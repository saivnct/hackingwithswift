//
//  ViewController.swift
//  Project4
//
//  Created by Giang Bui Binh on 6/25/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit
import WebKit

//ViewController class is made of: it inherits from UIViewController (the first item in the list), and promises its implements the WKNavigationDelegate protocol.
//The order here really is important: the parent class (superclass) comes first, then all protocols implemented come next, all separated by commas
class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    
    //Apple's solution to this is huge. Apple's solution is powerful. And, best of all, Apple's solution is almost everywhere in its toolkits, so once you learn how it works you can apply it elsewhere. It's called key-value observing (KVO), and it effectively lets you say, "please tell me when the property X of object Y gets changed by anyone at any time."
    //    We're going to use KVO to watch the estimatedProgress property, and I hope you'll agree that it's useful.
    var progressView: UIProgressView!
    
    var websites = ["apple.com", "hackingwithswift.com"]
    
    
    override func loadView() {
        webView = WKWebView()
        //The delegation solution is brilliant: we can tell WKWebView that we want to be told when something interesting happens. In our code, we're setting the web view's navigationDelegate property to self, which means "when any web page navigation happens, please tell me."
        webView.navigationDelegate = self;
        view = webView;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Warning: you need to ensure you use https:// for your websites, because iOS does not like apps sending or receiving data insecurely. If this is something you want to override, click here to read about App Transport Security in iOS 9.
        let urlRequest = URL(string: "https://"+websites[0])!
        webView.load(URLRequest(url: urlRequest))
        webView.allowsBackForwardNavigationGestures = true
        
        //The addObserver() method takes four parameters: who the observer is (we're the observer, so we use self), what property we want to observe (we want the estimatedProgress property of WKWebView), which value we want (we want the value that was just set, so we want the new one), and a context value.
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        //forKeyPath isn't named forProperty because it's not just about entering a property name. You can actually specify a path: one property inside another, inside another, and so on. More advanced key paths can even add functionality, such as averaging all elements in an array! Swift has a special keyword, #keyPath, which works like the #selector keyword you saw previously: it allows the compiler to check that your code is correct – that the WKWebView class actually has an estimatedProgress property
        //context is easier: if you provide a unique value, that same context value gets sent back to you when you get your notification that the value has changed. This allows you to check the context to make sure it was your observer that was called. There are some corner cases where specifying (and checking) a context is required to avoid bugs, but you won't reach them during any of this series.
        //Warning: in more complex applications, all calls to addObserver() should be matched with a call to removeObserver() when you're finished observing – for example, when you're done with the view controller.
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        //we're creating a new bar button item using the special system item type .flexibleSpace, which creates a flexible space. It doesn't need a target or action because it can't be tapped
        //you'll see the refresh button neatly aligned to the right – that's the effect of the flexible space automatically taking up as much room as it can on the left
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        progressView = UIProgressView(progressViewStyle: .default) //creates a new UIProgressView instance, giving it the default style. There is an alternative style called .bar, which doesn't draw an unfilled line to show the extent of the progress view, but the default style looks best here
        progressView.sizeToFit()        //tells the progress view set its layout size so that it fits its contents fully.
        let progressButton = UIBarButtonItem(customView: progressView)//creates a new UIBarButtonItem using the customView parameter, which is where we wrap up our UIProgressView in a UIBarButtonItem so that it can go into our toolbar
        
        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func openTapped(){
        
//We used the UIAlertController class in project 2, but here it's slightly different for three reason:
//        We're using nil for the message, because this alert doesn't need one.
//        We're using the preferredStyle of .actionSheet because we're prompting the user for more information.
//        We're adding a dedicated Cancel button using style .cancel. It doesn’t provide a handler parameter, which means iOS will just hide the alert controller if it’s tapped.
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for website in websites{
            ac.addAction(UIAlertAction(title: website, style: UIAlertActionStyle.default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
        //Warning: if you did not set your app to be targeted for iPhone at the beginning of this chapter, the above code will not work correctly. Yes, I know I told you to set iPhone, but a lot of people skip over things in their rush to get ahead. If you chose iPad or Universal, you will need to add ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem to the openTapped() method before presenting the alert controller.
        
        
    }
    
    func openPage(action: UIAlertAction){
        let urlRequest = URL(string: "https://"+action.title!)!
        webView.load(URLRequest(url: urlRequest))
    }
    
    
    //implement WKNavigationDelegate protocol.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    //implement WKNavigationDelegate protocol.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //This delegate callback allows us to decide whether we want to allow navigation to happen or not every time something happens. We can check which part of the page started the navigation, we can see whether it was triggered by a link being clicked or a form being submitted, or, in our case, we can check the URL to see whether we like it
        //Now that we've implemented this method, it expects a response: should we load the page or should we not? When this method is called, you get passed in a parameter called decisionHandler. This actually holds a function, which means if you "call" the parameter, you're actually calling the function
        
        //In project 2 I talked about closures: chunks of code that you can pass into a function like a variable and have executed at a later date. This decisionHandler is also a closure, except it's the other way around – rather than giving someone else a chunk of code to execute, you're being given it and are required to execute it.
        //And make no mistake: you are required to do something with that decisionHandler closure. That might make sound an extremely complicated way of returning a value from a method, and that's true – but it's also underestimating the power a little! Having this decisionHandler variable/function means you can show some user interface to the user "Do you really want to load this page?" and call the closure when you have an answer.
        
        //You might think that already sounds complicated, but I’m afraid there’s one more thing that might hurt your head. Because you might call the decisionHandler closure straight away, or you might call it later on (perhaps after asking the user what they want to do), Swift considers it to be an escaping closure. That is, the closure has the potential to escape the current method, and be used at a later date. We won’t be using it that way, but it has the potential and that’s what matters.
        
//        Because of this, Swift wants us to add the special keyword @escaping when specifying this method, so we’re acknowledging that the closure might be used later. You don’t need to do anything else – just add that one keyword, as you’ll see in the code below.
        
        let url = navigationAction.request.url
        
        if let host = url!.host {
            for website in websites {
                if host.contains(website) { //range(of:) String method to see whether each safe website exists somewhere in the host name.
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)    //if there is no host set, or if we've gone through all the loop and found nothing, we call the decision handler with a negative response: cancel loading
        
    }
    
    
    //Once you have registered as an observer using KVO, you must implement a method called observeValue(). This tells you when an observed value has changed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress"){
            progressView.progress = Float(webView.estimatedProgress)
            //Minor note: estimatedProgress is a Double, which as you should remember is one way of representing decimal numbers like 0.5 or 0.55555. Unhelpfully, UIProgressView's progress property is a Float, which is another (lower-precision) way of representing decimal numbers. Swift doesn't let you put a Double into a Float, so we need to create a new Float from the Double.
        }
    }

}

