//
//  ViewController.swift
//  Project19
//
//  Created by Giang Bb on 7/13/17.
//  Copyright © 2017 Giang Bb. All rights reserved.
//

import UIKit
import MapKit

//Using the assistant editor, please create an outlet for your map view called mapView. You should also set your view controller to be the delegate of the map view by Ctrl-dragging from the map view to the orange and white view controller button just above the layout area. You will also need to add import MapKit to ViewController.swift so it understands what MKMapView is.




//We already used Interface Builder to make our view controller the delegate for the map view, but if you want code completion to work you should also update your code to declare that the class conforms
class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(chooseMapType))
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        mapView.addAnnotations([london,oslo,paris,rome,washington])
        mapView.mapType = .standard
    }
    
    @objc func chooseMapType() {
        let ac = UIAlertController(title: "Map", message: "Choose View Type", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: setMapType))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: setMapType))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: setMapType))
        present(ac, animated: true)
    }
    
    func setMapType(action: UIAlertAction!) {
        
        switch action.title! {
        case "Standard":
            self.mapView.mapType = .standard
            break
        case "Hybrid":
            self.mapView.mapType = .hybrid
            break
        case "Satellite":
            self.mapView.mapType = .satellite
            break
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
    }
        
        
    //Every time the map needs to show an annotation, it calls a viewFor method on its delegate (in this situation our ViewController)
    //Customizing an annotation view is a little bit like customizing a table view cell or collection view cell, because iOS automatically reuses annotation views to make best use of memory. If there isn't one available to reuse, we need to create one from scratch using the MKPinAnnotationView class. Our custom annotation view is going to look a lot like the default view, with the exception that we're going to add a button that users can tap for more information. So, they tap the pin to see the city name, then tap its button to see more information. In our case, it's those fascinating facts I spent literally tens of seconds writing.
    
    //There are a couple of things you need to be careful of here. First, viewFor will be called for your annotations, but also Apple's. For example, if you enable tracking of the user's location then that's shown as an annotation and you don't want to try using it as a capital city. If an annotation is not one of yours, just return nil from the method to have Apple's default used instead.
    //1- Define a reuse identifier. This is a string that will be used to ensure we reuse annotation views as much as possible
    //2- Check whether the annotation we're creating a view for is one of our Capital objects.
    //3- Try to dequeue an annotation view from the map view's pool of unused views.
    //4- If it isn't able to find a reusable view, create a new one using MKPinAnnotationView and sets its canShowCallout property to true. This triggers the popup with the city name.
    //5- Create a new UIButton using the built-in .detailDisclosure type. This is a small blue "i" symbol with a circle around it.
    //6- If it can reuse a view, update that view to use a different annotation
    //7- If the annotation isn't from a capital city, it must return nil so iOS uses a default view.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //1
        let identifier = "Capital"
        
        //2 
        if annotation is Capital{
            //3
            var anotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if anotationView == nil {
                //4
                anotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                anotationView!.canShowCallout = true //triggers the popup with the city name
                anotationView!.tintColor = UIColor.blue
                
                //5 
                let btn = UIButton(type: .detailDisclosure)
                anotationView!.rightCalloutAccessoryView = btn
            }else{
                //6
                anotationView!.annotation = annotation
            }
            
            return anotationView
            
            
        }
        
        return nil
    }
    
    //When this method is called, you'll be told what map view sent it (we only have one, so that's easy enough), what annotation view the button came from (this is useful), as well as the button that was tapped.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let capital = view.annotation as! Capital
        let placename = capital.title
        let placeinfo = capital.info
        
        let ac = UIAlertController(title: placename, message: placeinfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }


}

