//
//  LocationCache
//  GymBuddyUp
//
//  Created by YiHuang on 10/10/2016.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation
import CoreLocation

class LocationCache : NSObject, CLLocationManagerDelegate {
    
    //MARK: Shared Instance
    static let sharedInstance : LocationCache = {
        let instance = LocationCache()
        return instance
    }()
    
    //MARK: Local Variable
    lazy var locationManager = CLLocationManager()
    lazy var currentLocation = CLLocation()
    var isGotLocation = false
    
    //MARK: Init
    override init() {
        super.init()
    }
    
    func setup() {
        print("LocationCache setup")
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            currentLocation = location
            if isGotLocation == false {
                isGotLocation = true
                // update to user_info
                print("locationManager")
                User.currentUser!.updateLastSeenLocation(currentLocation){ error in
                    User.currentUser!.userlocation = self.currentLocation
                    
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    

}