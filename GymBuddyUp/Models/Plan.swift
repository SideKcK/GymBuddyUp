//
//  Plan.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class Plan {
    enum Level: Int {
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
    
    var exercises: [Exercise]?
    var name: String?
    var description: String?
    var level: Level!
    
    init () {
        exercises = [Exercise()]
        name = "test plan"
        description = "this is a test plan description........ "
        level = .Beginner
    }
    
    //assign this plan as user's today plan
    //replace if plan exists
    func setTodayPlan (rep: Bool, completion:  (NSError?)->Void) {
        assignToUser(User.currentUser!, date: NSDate(), rep: rep, completion: completion)
    }
    
    func assignToUser(user: User, date: NSDate, rep: Bool, completion: (NSError?)->Void) {
        print("Assigning plan to User::: \(user.screenName)")
        print(self)
        completion(nil)
    }
    
    class func getTodayPlan(completion: (Plan!, NSError!) -> Void) {
        getPlan(User.currentUser!, date: NSDate(), completion: completion)
    }
    
    class func deleteTodayPlan(completion: (NSError!) -> Void) {
        completion(nil)
    }
    
    class func repeatTodayPlan(completion: (NSError!) -> Void) {
        getTodayPlan { (plan, error) in
            if let plan = plan {
                plan.setTodayPlan(true, completion: { (error) in
                    completion(error)
                })
            }else {
                completion(error)
            }
        }
    }
    
    class func getPlan(user: User!, date: NSDate!, completion: (Plan!, NSError!) -> Void) {
        print("Get plan of \(user.screenName) \(date.description)")
        completion (Plan(), nil)
    }
}