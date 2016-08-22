//
//  Exercise.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

let testURL = NSURL(string: "http://www.building-muscle101.com/images/bench_press.jpg")

class Exercise {
    
    struct Set {
        var amount: Int?
        var intermission: Int?
        var weight: Int?
        
        init (dict: NSDictionary) {
            self.amount = dict.valueForKey("amount") as? Int
            self.intermission = dict.valueForKey("intermission") as? Int
            self.weight = dict.valueForKey("weight") as? Int
        }
        
        static func setArrayFromDictArray(data:[NSDictionary]?) -> [Set?] {
            var sets = [Set?]()
            if data != nil {
                for dict in data! {
                    sets.append(Set(dict: dict))
                    }
            }
            return sets
        }
    }
    
    var id: Int!
    var name: String!
    var thumbnailURL: NSURL!
    var gifURL: NSURL!
    var description: String?
    var sort_order: Int?
    var unitType: UnitType!
    var set: [Set?]
    
    enum UnitType : Int {
        case Repetition = 0
        case DurationInSeconds = 1
        case DistanceInMiles = 2
        case RepByWeight = 3
    }
    
    init () {
        id = 1111
        name = "test exercise"
        thumbnailURL = testURL
        gifURL = testURL
        description = "this is a test exercise: The bench press is an upper body strength training exercise that consists of pressing a weight upwards from a supine position. The exercise works the pectoralis major as well as supporting chest, arm, and shoulder muscles such as the anterior deltoids, serratus anterior, coracobrachialis, scapulae fixers, trapezii, and the triceps."
        let tmpSet = Set(dict: ["amount": "10", "intermission": "10", "weight":"30"])
        set = [tmpSet]
    }
        
    init (id: Int, dict: NSDictionary) {
        self.id = id
        self.name = dict.valueForKey("name") as? String
        self.sort_order = dict.valueForKey("sort_order") as? Int
        self.description = dict.valueForKey("description") as? String
        self.thumbnailURL = testURL
        self.gifURL = testURL
        let typeVal = dict.valueForKey("type") as? Int
        self.unitType = UnitType(rawValue: (typeVal != nil ? typeVal!:0))
        self.set = Set.setArrayFromDictArray((dict.valueForKey("set") as? [NSDictionary]))
    }
}