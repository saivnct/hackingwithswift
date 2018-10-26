//
//  Person.swift
//  Project10
//
//  Created by Giang Bui Binh on 6/29/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit

//The Codable system works on both classes and structs. We made Person a class because NSCoding only works with classes, but if you didn’t care about Objective-C compatibility you could make it a struct and use Codable instead.
//When we implemented NSCoding in the previous chapter we had to write encode() and decodeObject() calls ourself. With Codable this isn’t needed unless you need more precise control - it does the work for you.
//When you encode data using Codable you can save to the same format that NSCoding uses if you want, but a much more pleasant option is JSON – Codable reads and writes JSON natively.
class Person: NSObject, Codable {
    var name: String
    var image:  String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

}
