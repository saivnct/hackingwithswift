//
//  Person.swift
//  Project10
//
//  Created by Giang Bui Binh on 6/29/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image:  String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
