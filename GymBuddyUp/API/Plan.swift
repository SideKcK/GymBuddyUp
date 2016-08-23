//
//  Plan.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation



class Plan {
    
    enum Difficulty: Int {
        case Beginner = 0
        case Mid = 1
        case Advanced = 2
        
        var description: String {
            switch self {
            case Beginner:
                return "Beginner"
            case Mid:
                return "Mid"
            case Advanced:
                return "Advanced"
            }
        }
    }
    
    var id: String!
    var name: String?
    var enabled: Bool
    var difficulty: Difficulty?
    var description: String?

    var exercises: [Exercise]?
    
    init () {
        id = "SAMPLEID"
        
        let random = Int(arc4random_uniform(10))
        exercises = [Exercise](count: random, repeatedValue: Exercise())

        name = "Test plan"
        description = "this is a test plan description........ "
        difficulty = .Beginner
        enabled = true
    }
    
    init (id: String, dict: NSDictionary) {
        self.id = id
        self.name = dict.valueForKey("name") as? String
        self.difficulty = Difficulty(rawValue: (dict.valueForKey("difficulty") as! Int))
        self.description = dict.valueForKey("description") as? String
        self.enabled = dict.valueForKey("enabled") as! Bool
    }

    class func planIDsWithArray(array: [ScheduledWorkout]?) -> [String]? {
        var res = [String]()
        
        guard let arr = array else {
            return res
        }
        for workout in arr {
            res.append(workout.planId)
        }
        return res
    }

    
}