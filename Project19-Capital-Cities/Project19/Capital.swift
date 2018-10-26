//
//  Capital.swift
//  Project19
//
//  Created by Giang Bb on 7/13/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import MapKit


//With map annotations, you can't use structs, and you must inherit from NSObject because it needs to interactive with Apple's Objective-C code.
//we're going to add some annotations to our map. Annotations are objects that contain a title, a subtitle and a position. The first two are both strings, the third is a new data type called CLLocationCoordinate2D, which is a structure that holds a latitude and longitude for where the annotation should be placed.
//Map annotations are described not as a class, but as a protocol. This is something you haven't seen before, because so far protocols have all been about methods. But if we want to conform to the MKAnnotation protocol, which is the one we need to adopt in order to create map annotations, it states that we must have a coordinate in our annotation. That makes sense, because there's no point in having an annotation on a map if we don't know where it is. The title and subtitle are optional, but we'll provide them anyway.
class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String){
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
    
    

}
