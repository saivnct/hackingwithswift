//
//  DetailViewController.swift
//  Project7
//
//  Created by Giang Bui Binh on 6/27/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var webview: WKWebView!
    var detailItem: [String: String]!
    
    override func loadView() {
        webview = WKWebView()
        view = webview
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // guard. This is used to create an "early return," which means you set your code up so that it exits immediately if critical data is missing. In our case, we don't want this code to run if detailItem isn't set, so guard will run return is detailItem is set to nil.
        guard detailItem != nil else {
            return
        }
        
        if let body = detailItem["body"] {
            var html = "<html>"
            html += "<head>"
            html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
            html += "<style> body { font-size: 150%; } </style>"
            html += "</head>"
            html += "<body>"
            html += body
            html += "</body>"
            html += "</html>"
            webview?.loadHTMLString(html, baseURL: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
