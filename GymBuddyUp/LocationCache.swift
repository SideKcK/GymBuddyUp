//
//  LocationCache
//  GymBuddyUp
//
//  Created by YiHuang on 10/10/2016.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation

class LocationCache : NSObject, CLLocationManagerDelegate {
    
    //MARK: Shared Instance
    static let sharedInstance : LocationCache = {
        let instance = LocationCache()
        return instance
    }()
    
    //MARK: Local Variable
    lazy var locationManager = CLLocationManager()
    lazy var currentLocation = CLLocation()
    
    //MARK: Init
    override init() {
        super.init()
    }
    
    func setup() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            currentLocation = location
        }
    }
    
    
}