//
//  PlayData.swift
//  Project39
//
//  Created by Giang Bb on 10/30/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//

import Foundation

class PlayData {
    var allWords = [String]()
//    var wordCounts = [String: Int]()
    var wordCounts: NSCountedSet! //a set data type, which means that items can only be added once. But it's a specialized set object: it keeps track of how many times items you tried to add and remove each item, which means it can handle de-duplicating our words while storing how often they are used
    private(set) var filteredWords = [String]()
    
    init() {
        if let path = Bundle.main.path(forResource: "plays", ofType: "txt") {
            if let plays = try? String(contentsOfFile: path) {
                allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted) //Previously we used components(separatedBy:) to convert a string into an array, but this time the method is different because we pass in a character set rather than string. This new method splits a string by any number of characters rather than a single string, which is important because we want to split on periods, question marks, exclamation marks, quote marks and more
                
                allWords = allWords.filter { $0 != "" } //a function that accepts a function as a parameter, like filter(), is called a higher-order function, and allows you to write extremely concise, expressive code that is efficient to run
                
                //That one line is all it takes to remove empty lines from the allWords array. However, this syntax can look like line noise if you're new to Swift, so I want to deconstruct what it does by first rewriting that code in a way you're more familiar with. I don't want you to put any of this into your code – this is just to help you understand what's going on.
                
                //Here is that one line written out more verbosely:
//                allWords = allWords.filter({ (testString: String) -> Bool in
//                    if testString != "" {
//                        return true
//                    } else {
//                        return false
//                    }
//                })
                
                //slow code
//                for word in allWords {
//                    if wordCounts[word] == nil {
//                        wordCounts[word] = 1
//                    } else {
//                        wordCounts[word]! += 1
//                    }
//                }
//
//                allWords = Array(wordCounts.keys)
            
                
                
                wordCounts = NSCountedSet(array: allWords) ////creates a counted set from all the words, which immediately de-duplicates and counts them all
                let sorted = wordCounts.allObjects.sorted { wordCounts.count(for: $0) > wordCounts.count(for: $1) }
                allWords = sorted as! [String]
                
            }
        }
        
        
    }
    
    func applyFilter(_ filter: (String) -> Bool) {
//        filteredWords = allWords.filter(filter)
        allWords = allWords.filter(filter)
    }
    
    func applyUserFilter(_ input: String) {
        if let userNumber = Int(input) {
            applyFilter { self.wordCounts.count(for: $0) >= userNumber }
        } else {
            applyFilter { $0.range(of: input, options: .caseInsensitive) != nil }
        }
    }
}
