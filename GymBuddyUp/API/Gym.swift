//
//  Gym.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class Gym {
    var placeid: String?
    var name: String?
    var location: CLLocationCoordinate2D?
    var address: String?
    
    init () {
//        self.name = "test gym"
//        self.placeid = "-1"
//        self.address = "XXX University Dr, College Station"
//        self.location = CLLocationCoordinate2D(latitude: 30.563, longitude: -96.311)
    }
    
    init(dict: NSDictionary) {
        if let address = dict["vicinity"] as? String {
            self.address = address
        }
            if let name = dict["name"] as? String {
                self.name = name
            }
        if let id = dict["place_id"] as? String {
            self.placeid = id
        }
        if let geo = dict["geometry"] as? NSDictionary,
            let loc = geo["location"] as? NSDictionary,
            let lat = loc["lat"] as? CLLocationDegrees,
            let lng = loc["lng"] as? CLLocationDegrees {
            self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
    
    init(place: GMSPlace) {
        self.address = place.formattedAddress
        self.location = place.coordinate
        self.placeid = place.placeID
        self.name = place.name
    }
    
    class func gymsWithArray(array: [NSDictionary]) -> [Gym] {
        var gyms = [Gym]()

        for dictionary in array {
            gyms.append(Gym(dict: dictionary))
        }
        return gyms
    }
}

