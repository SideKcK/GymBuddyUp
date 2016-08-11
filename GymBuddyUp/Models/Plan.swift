//
//  Plan.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation

import Firebase
import FirebaseDatabase
import FirebaseStorage



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
    
    var id: String
    var name: String?
    var enabled: Bool
    var difficulty: Difficulty?
    var description: String?

    var exercises: [Exercise]?
    
    init () {
        id = "SAMPLEID"
        exercises = [Exercise()]
        name = "test plan"
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

    //////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    
    
    func setTodayPlan(repeatPlan: Bool, completion: (NSError!) -> Void) {
        completion(nil);
    }
    
    class func getTodayPlan(completion: (Plan!, NSError!) -> Void) {
        completion(Plan(), nil);
    }
    
    class func deleteTodayPlan(completion: (NSError!) -> Void) {
        
    }
    
    class func repeatTodayPlan(completion: (NSError!) -> Void) {
        getTodayPlan { (plan, error) in
            if plan != nil {
                completion(nil)
                }
        }

    }
    
    class func getPlan(user: User!, date: NSDate!, completion: (Plan!, NSError!) -> Void) {
        print("Get plan of \(user.screenName) \(date.description)")
        completion (Plan(), nil)
    }
}