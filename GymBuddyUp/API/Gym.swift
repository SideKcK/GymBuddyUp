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
import ObjectMapper

class Gym: Mappable {
    var placeid: String?
    var name: String?
    var location: CLLocation?
    var address: String?
    
    required init?(_ map: Map) {
        
    }
    
    
    // Mappable
    func mapping(map: Map) {
        name <- map["name"]
        address <- map["address"]
        placeid <- map["place_id"]
        var lat: Double?
        var long: Double?
        lat <- map["lat"]
        long <- map["long"]
        if let _lat = lat,
            let _long = long {
            location = CLLocation(latitude: _lat, longitude: _long)
        }
    }
    
    init () {
        self.name = "test gym"
        self.placeid = "-1"
        self.address = "XXX University Dr, College Station"
        self.location = CLLocation(latitude: 30.563, longitude: -96.311)
    }
    

    init? (fromGooglePlace: NSDictionary) {
        self.address =  fromGooglePlace["vicinity"] as? String
        self.name = fromGooglePlace["name"] as? String
        self.placeid = fromGooglePlace["place_id"] as? String
        
        if let geo = fromGooglePlace["geometry"] as? NSDictionary,
            let loc = geo["location"] as? NSDictionary,
            let lat = loc["lat"] as? CLLocationDegrees,
            let lng = loc["lng"] as? CLLocationDegrees {
            self.location = CLLocation(latitude: lat, longitude: lng)
        }
        else {
            return nil
        }
    }
    
    init? (fromFirebase: NSDictionary)
    {
        self.name = fromFirebase.valueForKey("name") as? String
        self.address = fromFirebase.valueForKey("address") as? String
        self.placeid = fromFirebase.valueForKey("place_id") as? String
        if let lat = fromFirebase.valueForKey("lat") as? CLLocationDegrees,
        let long = fromFirebase.valueForKey("long") as? CLLocationDegrees {
            self.location = CLLocation(latitude: lat, longitude: long)
        }
        else {
            return nil
        }
    }
    
    init(place: GMSPlace) {
        self.address = place.formattedAddress
        self.location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.placeid = place.placeID
        self.name = place.name
    }
    
    //init ()
    
    func toDictionary() -> NSDictionary? {
        var dict = [String: AnyObject]()
        dict["place_id"] = self.placeid
        dict["name"] = self.name
        dict["address"] = self.address

        guard self.location != nil
        else {
            return nil
        }
        
        dict["lat"] = self.location!.coordinate.latitude
        dict["long"] = self.location!.coordinate.longitude

        return dict
    }
    
    class func gymsWithArray(array: [NSDictionary]) -> [Gym] {
        var gyms = [Gym]()

        for dictionary in array {
            gyms.append(Gym(fromGooglePlace: dictionary)!)
        }
        return gyms
    }
}

