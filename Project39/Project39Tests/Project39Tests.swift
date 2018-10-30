//
//  Project39Tests.swift
//  Project39Tests
//
//  Created by Giang Bb on 10/30/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//

import XCTest
@testable import Project39

class Project39Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //the method has a very specific name: it starts with "test" all in lowercase, it accepts no parameters and returns nothing. When you create a method like this inside an XCTestCase subclass, Xcode automatically considers it to be a test that should run on your code. When Xcode recognizes a test, you'll see an empty gray diamond appear in the left-hand gutter, next to the line numbers. If you hover over that – but don't click it just yet! – it will turn into a play button, which will run the test
    func testAllWordsLoaded() {
        let playData = PlayData()
//        XCTAssertEqual(playData.allWords.count, 0, "allWords must be 0")
        XCTAssertEqual(playData.allWords.count, 384001, "allWords was not 384001")
    }
    
    func testWordCountsAreCorrect() {
        let playData = PlayData()
        XCTAssertEqual(playData.wordCounts.count(for: "home"), 174, "Home does not appear 174 times")
        XCTAssertEqual(playData.wordCounts.count(for: "fun"), 4, "Fun does not appear 4 times")
        XCTAssertEqual(playData.wordCounts.count(for: "mortal"), 41, "Mortal does not appear 41 times")
    }
    
    //XCTest makes performance testing extraordinarily easy: you give it a closure to run, and it will execute that code 10 times in a row. You'll then get a report back of how long the call took on average, what the standard deviation was (how much variance there was between runs), and even how fast each of those 10 runs performed if you want the details
    func testWordsLoadQuickly() {
        measure {
            _ = PlayData()
        }
    }
    
    
    func testUserFilterWorks() {
        let playData = PlayData()
        
        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495)
        
        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55)
        
        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1)
        
        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56)
        
        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7)
        
        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0)
    }
}
