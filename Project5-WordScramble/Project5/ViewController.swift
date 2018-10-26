//
//  ViewController.swift
//  Project5
//
//  Created by Giang Bui Binh on 6/26/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {

    var allWords = [String] ()
    var usedWords = [String] ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let filePath = Bundle.main.path(forResource: "start", ofType: "txt"){
            if let contentString = try? String(contentsOfFile: filePath){   //try? means "call this code, and if it throws an error just send me back nil instead.
                allWords = contentString.components(separatedBy: "\n")
            }
        }else {
            allWords = ["silworm"]
        }
        
        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - config table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
       cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
    
    //MARK: - Game config
    func startGame() {
        //shuffle the allWords array
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        
        
        tableView.reloadData()  //it calls the reloadData() method of tableView. That table view is given to us as a property because our ViewController class comes from UITableViewController
        
    }
    
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        //Swift "captures" any constants and variables that are used in a closure, based on the values of the closure's surrounding context. That is, if you create an integer, a string, an array and another class outside of the closure, then use them inside the closure, Swift captures them.
        //This is important, because the closure references the variables, and might even change them. But I haven't said yet what "capture" actually means, and that's because it depends what kind of data you're using. Fortunately, Swift hides it all away so you don't have to worry about it…
        //…except for those strong reference cycles I mentioned. Those you need to worry about. That's where objects can't even be destroyed because they all hold tightly on to each other – known as strong referencing.
        //First, you must tell Swift what variables you don't want strong references for. This is done in one of two ways: unowned or weak. These are somewhat equivalent to implicitly unwrapped optionals (unowned) and regular optionals (weak): a weakly owned reference might be nil, so you need to unwrap it; an unowned reference is one you're certifying cannot be nil and so doesn't need to be unwrapped, however you'll hit a problem if you were wrong.
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            
            //declares "self" (the current view controller) and "ac" (our UIAlertController) to be captured as "unowned" references inside the closure. It means the closure can use them, but won't create a strong reference cycle because we've made it clear the closure doesn't own either of them
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        //trailing closure syntax
        //Any time you are calling a method that expects a closure as its final parameter – and there are many of them – you can eliminate that final parameter entirely, and pass it inside braces instead
        //UIAlertAction(title: "Continue", style: .default) {
        //        CLOSURE CODE HERE
        //    }
        
        //The "in" keyword is important: everything before that describes the closure; everything after that is the closure. So (action: UIAlertAction) in means that it accepts one parameter in, of type UIAlertAction.
        
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    func submit(answer: String)  {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) && isOriginal(word: lowerAnswer) && isReal(word: lowerAnswer) {
            usedWords.insert(lowerAnswer, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
//            tableView.reloadData()
            //we insert a new row into the table view. Given that the table view gets all its data from the used words array, this might seem strange. After all, we just inserted the word into the usedWords array, so why do we need to insert anything into the table view?
            
//            The answer is animation. Like I said, we could just call the reloadData() method and have the table do a full reload of all rows, but it means a lot of extra work for one small change, and also causes a jump – the word wasn't there, and now it is.
            
//            This can be hard for users to track visually, so using insertRows() lets us tell the table view that a new row has been placed at a specific place in the array so that it can animate the new cell appearing. Adding one cell is also significantly easier than having to reload everything, as you might imagine!
            
            //the with parameter lets you specify how the row should be animated in. Whenever you're adding and removing things from a table, the .automatic value means "do whatever is the standard system animation for this change." In this case, it means "slide the new row in from the top."
            
        }else{
            let ac = UIAlertController(title: "Wrong word", message: "You enter wrong word", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        
        }
    }
    
    //# MARK: - Check words
    func isPossible(word: String) -> Bool {
        var temp = title!.lowercased()
        
        for letter in word.characters {
            //range(of:) returns an optional position of where the item was found – meaning that it might be nil. So, we wrap the call into an if let to safely unwrap the optional
            if let pos = temp.range(of: String(letter)){
                temp.remove(at: pos.lowerBound)
            }else {
                return false
            }
        }
        
        return true
    }
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    func isReal(word: String) -> Bool {
        //There's a new class here, called UITextChecker. This is an iOS class that is designed to spot spelling errors, which makes it perfect for knowing if a given word is real or not. We're creating a new instance of the class and putting it into the checker constant for later
        let checker = UITextChecker()
        
        //There's a new function call here too, called NSMakeRange(). This is used to make a string range, which is a value that holds a start position and a length. We want to examine the whole string, so we use 0 for the start position and the string's length for the length.
        let range = NSMakeRange(0, word.utf16.count)
        //there’s one small thing I want to touch on briefly. In the isPossible() method we looped over each letter by accessing the word.characters array, but in this new code we use word.utf16 instead. Why?
        //The answer is an annoying backwards compatibility quirk: Swift’s strings natively store international characters as individual characters, e.g. the letter “é” is stored as precisely that. However, UIKit was written in Objective-C before Swift’s strings came along, and it uses a different character system called UTF-16 – short for 16-bit Unicode Transformation Format – where the accent and the letter are stored separately.
        //I realize this seems like pointless additional complexity, so let me try to give you a simple rule: when you’re working with UIKit, SpriteKit, or any other Apple framework, use utf16.count for the character count. If it’s just your own code - i.e. looping over characters and processing each one individually – then use characters.count instead
        
        
        
        //Next, we call the rangeOfMisspelledWord(in:) method of our UITextChecker instance. This wants five parameters, but we only care about the first two and the last one: the first parameter is our string, word, the second is our range to scan (the whole string), and the last is the language we should be checking with, where en selects English.
        //Parameters three and four aren't useful here, but for the sake of completeness: parameter three selects a point in the range where the text checker should start scanning, and parameter four lets us set whether the UITextChecker should start at the beginning of the range if no misspelled words were found starting from parameter three. Neat, but not helpful here.
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        //Calling rangeOfMisspelledWord(in:) returns an NSRange structure, which tells us where the misspelling was found. But what we care about was whether any misspelling was found, and if nothing was found our NSRange will have the special location NSNotFound. Usually location would tell you where the misspelling started, but NSNotFound is telling us the word is spelled correctly – i.e., it's a valid word.
        return misspelledRange.location == NSNotFound
    }
    
    

}

