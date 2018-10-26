//
//  Person.swift
//  Project10
//
//  Created by Giang Bui Binh on 6/29/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit

//Using NSCoding protocol to save object to UserDefault
//Once you conform to the NSCoding protocol, The protocol requires you to implement two methods: a new initializer and encode().
class Person: NSObject, NSCoding {
    var name: String
    var image:  String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    
    //you'll be using a new class called NSCoder. This is responsible for both encoding (writing) and decoding (reading) your data so that it can be used with UserDefaults
    //The initializer is used when loading objects of this class, and encode() is used when saving
    
    //the new initializer must be declared with the required keyword. This means "if anyone tries to subclass this class, they are required to implement this method." An alternative to using required is to declare that your class can never be subclassed, known as a final class, in which case you don't need required because subclassing isn't possible. We'll be using required here
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        image = aDecoder.decodeObject(forKey: "image") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(image, forKey: "image")
    }
}
