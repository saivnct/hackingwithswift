//
//  AddCommentsViewController.swift
//  Project33
//
//  Created by Giang Bb on 10/29/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//

import UIKit

class AddCommentsViewController: UIViewController, UITextViewDelegate {
    var genre: String!
    
    var comments: UITextView!   //unlike UITextField, you can’t give a UITextView a placeholder string, which is a piece of text telling users what to type in there. We'll replicate this behavior by putting a default string into the text view and removing it when the user taps it.
    let placeholder = "If you have any additional comments that might help identify your tune, enter them here."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
        comments.text = placeholder
    }
    
    override func loadView() {
        super.loadView()
        
        comments = UITextView()
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.delegate = self
        comments.font = UIFont.preferredFont(forTextStyle: .body)
        view.addSubview(comments)
        
        comments.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        comments.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        comments.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        comments.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    @objc func submitTapped() {
        let vc = SubmitViewController()
        vc.genre = genre
        
        if comments.text == placeholder {
            vc.comments = ""
        } else {
            vc.comments = comments.text
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: - IMPLEMENT UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
        }
    }

}
