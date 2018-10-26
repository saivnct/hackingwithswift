//
//  ViewController.swift
//  Project31
//
//  Created by Giang Bui Binh on 9/27/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

// our app already supports multitasking pretty well, although we'll make it better in a moment. First, though: what if you're upgrading existing apps? Well, you might not have such an easy ride, but if your code is modern you're probably still OK. To make multitasking work, you need to
    //Have a launch XIB. This is the same thing that enables iPhone 6 support with iOS 8, and has been created for new projects ever since iOS 8 was released, so you probably already have one. If not, add a new file, choose User Interface, then Launch Screen. Then, in your plist, add a key for "Launch screen interface file base name" and point it to the name of your launch XIB, without the ".xib" extension. For example, if your launch screen is called LaunchScreen.xib, give this key the value of "LaunchScreen".
    //Make sure your app is configured to support all orientations. This may already be configured this way, but if not make sure you choose all orientations now. As you might imagine, selectively choosing only some orientations would cause havoc with multitasking!
    //Use Auto Layout everywhere. If your app pre-dates Auto Layout or if you found it intimidating at first, you might still be struggling along with autoresizing masks. Now is the time to change: the various multitasking sizes make Auto Layout a no-brainer.
    //Use adaptive UI wherever needed. Adaptive layout is Apple's term for technologies like Size Classes and Dynamic Type, the former of which is a huge advantage when working with multitasking. Size Classes let you make your interface adjust to two major screen sizes, compact and regular, which previously were great for working with iPhone and iPad, but are now also used for iPad multitasking.

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    //We're going to track the active web view
    weak var activeWebView: UIWebView?  //It's weak because it might go away at any time if the user deletes it.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setDefaultitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebview))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebview))
        navigationItem.rightBarButtonItems = [delete,add]
        
        addressBar.delegate = self
        
    }
    
    func setDefaultitle() {
        title = "Giangdaika"
    }
    
    @objc func addWebview()  {
        let webView = UIWebView()
        webView.delegate = self
        
        // a method on the stack view called addArrangedSubview() and not addSubview(). That's worth repeating, because it's extremely important: you do not call addSubview() on UIStackView. The stack view has its own subviews that it manages invisibly to you. Instead, you add to its arranged subviews array, and the stack view will arrange them as needed.
        stackView.addArrangedSubview(webView)
        let url = URL(string: "https://google.com")!    //Remember, iOS apps can only load HTTPS websites by default, and you need to enable App Transport Security exceptions if you want to load non-secure websites.
        webView.loadRequest(URLRequest(url: url))
    
        //Notice that we don't need to give the web view a frame or any Auto Layout constraints – that's all handled for us by UIStackView.
        
        
        selectWebview(webView)
        // handling taps
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
    }
    func updateUI(for webView: UIWebView) {
        title = webView.stringByEvaluatingJavaScript(from: "document.title")
        addressBar.text = webView.request?.url?.absoluteString ?? ""
    }
    
    func selectWebview(_ webView: UIWebView) {
        //The selectWebView() method is straightforward: it needs to loop through the array of web views belonging to the stack view, updating each of them to have a zero-width border line, then set the newly selected one to have a border width of three points
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        activeWebView = webView
        webView.layer.borderWidth = 3
        webView.layer.borderColor = UIColor.blue.cgColor
        
        updateUI(for: webView)
    }
    
    @objc func deleteWebview() {
        //We want the delete button to work only if there's a web view selected.
        //We want to find the location of the active web view inside the stack view, then remove it.
        //If there are now no more web views, we want to call setDefaultTitle() to reset the user interface.
        //We need to find whatever web view immediately follows the one that was removed.
        //We then make that the new selected web view, highlighting it in blue.
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.index(of: webView){
                // we found the current webview in the stack view! Remove it from the stack view
                stackView.removeArrangedSubview(webView)
                
                // now remove it from the view hierarchy – this is important!
                // The reason is that you can remove something from a stack view's arranged subview list then re-add it later, without having to recreate it each time – it was hidden, not destroyed. We don't want a memory leak, so we want to remove deleted web views entirely. If you find your memory usage ballooning, you probably forgot this step!
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    setDefaultitle()
                }else {
                    // convert the Index value into an integer
                    var currentIndex = Int(index)
                    
                    // if that was the last web view in the stack, go back one
                    if currentIndex == stackView.arrangedSubviews.count{
                        currentIndex = stackView.arrangedSubviews.count - 1;
                    }
                    
                    // find the web view at the new index and select it
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? UIWebView {
                        selectWebview(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    @objc func webViewTapped(_ regconizer: UITapGestureRecognizer)  {
        if let selectedWebView = regconizer.view as? UIWebView {
            selectWebview(selectedWebView)
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
    
    //MARK: - IMPLEMENT UIGestureRecognizerDelegate
    // need to tell iOS we want these gesture recognizers to trigger alongside the recognizers built into the UIWebView, so add this
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    //MARK: - IMPLEMENT UITextFieldDelegate
    // we need to detect when the user enters a new URL in the address bar. We already set this view controller to be the delegate of the address bar, so we'll get sent the textFieldShouldReturn() delegate method when the user presses Return on their iPad keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Notice that there are a few if lets in there to make sure all the data is unwrapped safely, and particularly important is the URL: if you try to enter a URL without “https://“ iOS will reject it. That's something you can fix later!
        if let webview = activeWebView, let address = addressBar.text {
            if let url = URL(string: address) {
                webview.loadRequest(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()    //call resignFirstResponder() on the text field so that the keyboard hides
        return true
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Even though this particular project works with multitasking by default, it doesn't have any adaptive user interface built in. As a result, if we use multitasking the other way – i.e., if it's our app that is the one occupying 1/3rd of the screen while some other app has the remainder – then it looks terrible: our vertically stacked web views end up being so thin that they are unusable.
    //The solution is simple: we're going to tell the stack view to arrange its web views horizontally when we have lots of space, and vertically when we don't. This is done using the traitCollectionDidChange() method, which gets called automatically when our app's size class has changed. We can then query which size class we now have, and adapt our user interface.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //There is one complication, and that's understanding size classes. There are two axes for size classes, namely horizontal and vertical, and each of them has two sizes, Compact and Regular. No matter what orientation or multitasking setup, the vertical size class is always regular on iPad. For the other possibilities, here are the key rules:
            //An iPad app running by itself in portrait or landscape has a regular horizontal size classes.
            //In landscape where the apps are split 50/50, both are running in a compact horizontal size class.
            //In landscape where the apps are split 70/30, the app on the left is a regular horizontal size class and the app on the right is compact.
            //In portrait where the apps are split 60/40, both are running in a compact horizontal size class.
        //We're going to use this information so that we detect when the size class has changed and update our stack view appropriately. When we have a regular horizontal size class we'll use horizontal stacking, and when we have a compact size class we'll use vertical stacking
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        }else {
            stackView.axis = .horizontal
        }
    }
    


}

