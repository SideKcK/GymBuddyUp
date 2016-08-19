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
    var id: Int!
    var name: String!
    var thumbnailURL: NSURL!
    var gifURL: NSURL!
    var description: String?
    var sort_order: Int?
    var unitType: UnitType!
    var amount: Int? 
    var intermission: Int?
    var order: Int?
    
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
    }
        
    init (id: Int, dict: NSDictionary) {
        self.id = id
        self.name = dict.valueForKey("name") as? String
        self.sort_order = dict.valueForKey("sort_order") as? Int
        self.description = dict.valueForKey("description") as? String
        self.thumbnailURL = testURL
        self.gifURL = testURL
        self.unitType = UnitType.Repetition
    }
}