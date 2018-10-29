//
//  SubmitViewController.swift
//  Project33
//
//  Created by Giang Bb on 10/29/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//
import CloudKit
import UIKit

class SubmitViewController: UIViewController {

    var genre: String!
    var comments: String!
    
    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //we're going to hide the navigation bar's back button so the user can't back out of the view controller until submission has finished
        title = "You're all set!"
        navigationItem.hidesBackButton = true
    }
    

    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Submitting…"
        status.textColor = UIColor.white
        status.font = UIFont.preferredFont(forTextStyle: .title1)
        status.numberOfLines = 0
        status.textAlignment = .center
        
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView.addArrangedSubview(status)
        stackView.addArrangedSubview(spinner)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //The first is viewDidAppear(), which we'll use to start the submission process
        doSubmission()
    }
    
    func doSubmission() {
        
    }
    
    @objc func doneTapped() {
        _ = navigationController?.popToRootViewController(animated: true) //pops off all the view controllers on a navigation controller's stack, returning us to the original view controller - in our case, that's the "What's that Whistle?" screen with the + button
        //assign the result of popToRootViewController() to _, which is Swift’s way of saying “ignore this thing.” This silences an “unused result” warning, because although this method returns the array of view controllers that got removed, we don’t care about that, so we can throw it away
    }

}
