//
//  ViewController.swift
//  Project22
//
//  Created by Giang Bui Binh on 8/21/17.
//  Copyright © 2017 giangbb. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var distanceReading: UILabel!
    
    var locationManager: CLLocationManager! //This is the Core Location class that lets us configure how we want to be notified about location, and will also deliver location updates to us
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()    //This is where the actual action happens: if you have already been granted location permission then things will Just Work; if you haven't, iOS will request it now.
        //Note: if you used the "when in use" key, you should call requestWhenInUseAuthorization() instead. If you did not set the correct plist key earlier, your request for location access will be ignored.
        //Requesting location authorization is a non-blocking call, which means your code will carry on executing while the user reads your location message and decides whether to grant you access to their location
        
        
        
        view.backgroundColor = UIColor.gray
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //When the user has finally made their mind, you'll get told their result because we set ourselves as the delegate for our CLLocationManager object. The method that will be called is this one:
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {    //did we get authorized by the user
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){ // If so, is our device able to monitor iBeacons?
                if CLLocationManager.isRangingAvailable(){  //If so, is ranging available? (Ranging is the ability to tell roughly how far something else is away from our device.)
                    startScanning() //we only start scanning for beacons when we have permission and if the device is able to do so.
                }
                
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5") // The UUID I'm using there is one of the ones that comes built into the Locate Beacon app – look under "Apple AirLocate 5A4BCFCE" and find it there
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: 123, minor: 456, identifier: "MyBeacon") //Note that I'm scanning for specific major and minor numbers, so please enter those into your Locate Beacon app.
        //The identifier field is just a string you can set to help identify this beacon in a human-readable way. That, plus the UUID, major and minor fields, goes into the CLBeaconRegion class, which is used to identify and work with iBeacons
        
        //beaconRegion then gets sent to our location manager, asking it to monitor for the existence of the region and also to start measuring the distance between us and the beacon.
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }

    func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) { [unowned self] in
            switch distance{
            case .unknown:
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
                break
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"
                break
            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"
                break
            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"
                break
            }
        }
    }
    
    //MARK: - IMPLEMENT CLLocationManagerDelegate
    //to catch the ranging method from CLLocationManager. We'll be given the array of beacons it found for a given region, which allows for cases where there are multiple beacons transmitting the same UUID
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //If we receive any beacons from this method, we'll pull out the first one and use its proximity property to call our update(distance:) method and redraw the user interface. If there aren't any beacons, we'll just use .unknown, which will switch the text back to "UNKNOWN" and make the background color gray.
        if beacons.count > 0 {
            let beacon = beacons[0]
            update(distance: beacon.proximity)
        }else{
            update(distance: .unknown)
        }
        
    }
    


}

