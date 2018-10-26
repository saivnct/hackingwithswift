//
//  ViewController.swift
//  Project8
//
//  Created by Giang Bui Binh on 6/28/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    
    @IBOutlet weak var clueslabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solution = [String]()
    
    
    
    var score: Int = 0 {        //property observers, and it lets you execute code whenever a property has changed
        //Note that when you use a property observer like this, you need to explicitly declare its type otherwise Swift will complain.
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //you'll notice we don't have @IBOutlet references to any of our buttons, and that's entirely intentional: it wouldn't be very smart to create an @IBOutlet for every button. Interface Builder does have a solution to this, called Outlet Collections, which are effectively an IBOutlet array, but even that solution requires you to Ctrl-drag from every button and quite frankly I don't think you have the patience after spending so much time in Interface Builder!
        //As a result, we're going to take a simple shortcut. And this shortcut will also deal with calling methods when any of the buttons are tapped, so all in all it's a clean and easy solution. The shortcut is this: all our buttons have the tag 1001, so we can loop through all the views inside our view controller, and modify them only if they have tag 1001
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside) //addTarget(). This is the code version of Ctrl-dragging in a storyboard and it lets us attach a method to the button click
        }
        
        self.loadlevel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadlevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt"){
            if let levelContent = try? String(contentsOfFile: levelFilePath){
                var lines = levelContent.components(separatedBy: "\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
                
                for (index,line) in lines.enumerated(){//using the enumerated() method to loop over an array. it's helpful because it passes you each object from an array as part of your loop, as well as that object's position in the array
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index+1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.count) letters\n"
                    solution.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
                
            }
        }
        
        //config buttons and labels
        clueslabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answerLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]
        
        if letterBits.count == letterButtons.count{
            for i in 0..<letterBits.count{
                letterButtons[i].setTitle("\(letterBits[i])", for: .normal)
            }
        }
    }
    
    
    //MARK: - action from view
    @objc func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.isHidden = true
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        if level > 2 {
            level = 1
        }
        
        solution.removeAll(keepingCapacity: true)
        
        loadlevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if let solutionPosition = solution.index(of: currentAnswer.text!){
            activatedButtons.removeAll()
            
            var splitClues = answerLabel.text!.components(separatedBy: "\n")
            splitClues[solutionPosition] = currentAnswer.text!
            answerLabel.text = splitClues.joined(separator: "\n")
            
            
            currentAnswer.text = ""
            score += 1
            
            if score % 7 == 0{
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        }else{
            currentAnswer.text = ""
            for button in activatedButtons
            {
                button.isHidden = false
            }
            
            activatedButtons.removeAll()
        }
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        for button in activatedButtons
        {
            button.isHidden = false
        }
        
        activatedButtons.removeAll()
    }


}

