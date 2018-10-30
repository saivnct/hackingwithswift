//
//  Commit+CoreDataClass.swift
//  Project38
//
//  Created by Giang Bb on 10/30/18.
//  Copyright © 2018 Giang Bb. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
