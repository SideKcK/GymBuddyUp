//
//  Gym.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation

class Gym {
    var placeid: String?
    var name: String?
    var location: CLLocation?
    
    init () {
        self.name = "test gym"
        self.placeid = "-1"
    }
    
    init(dict: NSDictionary) {
        if let address = dict["vicinity"] as? String {
            if let name = dict["name"] as? String {
                self.name = name
                print(name)
            }
        }
        //self.name =
    }
    
    class func gymsWithArray(array: [NSDictionary]) -> [Gym] {
        var gyms = [Gym]()

        for dictionary in array {
            gyms.append(Gym(dict: dictionary))
        }
        return gyms
    }
}

