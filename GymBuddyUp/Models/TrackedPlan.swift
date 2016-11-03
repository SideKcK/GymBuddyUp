//
//  Tracking.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/17/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation


import SwiftDate


class TrackedPlan {
    var plan: Plan?
    var planId: String?
    var trackingId: String? //format  is  “eventId:date”
    var startDate : NSDate?
    var endDate: NSDate?
    var user: User?
    var scheduledWorkout: String?
    var trackingItems = [TrackedItem]()
    var gym: Gym?
    
    init(plan: Plan) {
        self.plan = plan
        if let exercises = plan.exercises {
            for exercise in exercises {
                let trackingItem =  TrackedItem(_exercise: exercise)
                trackingItems.append(trackingItem)
            }
        }
    }
    
    init(scheduledWorkout: String, plan: Plan) {
        self.scheduledWorkout = scheduledWorkout
        self.plan = plan
        if let exercises = plan.exercises {
            for exercise in exercises {
                let trackingItem =  TrackedItem(_exercise: exercise)
                trackingItems.append(trackingItem)
            }
        }
    }
     
    init(planId: String) {

    }

    init(planDict: NSDictionary) {

    }
    
    init(trackingId:String, data: NSDictionary)
    {
        self.trackingId = trackingId
        self.scheduledWorkout = data.valueForKey("scheduled_workout") as? String
        self.startDate = NSDate(timeIntervalSince1970: Double(data.valueForKey("start_time") as! Int))
        self.endDate = NSDate(timeIntervalSince1970: Double(data.valueForKey("end_time") as! Int))
        self.planId = data.valueForKey("plan_id") as? String
        self.trackingItems = [TrackedItem]()
        if let _gym = data.valueForKey("gym") as? NSDictionary {
            print("_gym is not nil")
            self.gym = Gym(fromFirebase: _gym)
        }
        //self.workoutLog = [String: AnyObject]()
        
    }
    
    init(trackingId:String, scheduledWorkout:String, startDate: Int, endDate: Int, planId:String, trackingItems: [TrackedItem])
    {
        self.trackingId = trackingId
        self.scheduledWorkout = scheduledWorkout
        self.startDate = NSDate(timeIntervalSince1970: Double(startDate))
        self.endDate = NSDate(timeIntervalSince1970: Double(endDate))
        self.planId = planId
        self.trackingItems = trackingItems
    }
    
    class func initFromQueryResults(queryResults: NSDictionary?) -> [TrackedPlan]
    {
        if queryResults != nil {
            
            var trackingArray = [TrackedPlan]()
            for trackingId in queryResults!.allKeys
            {
                let data = queryResults![trackingId as! String] as! NSDictionary
                trackingArray.append(TrackedPlan(trackingId: trackingId as! String, data: data))
            }
            return trackingArray
        } else {
            return []
        }
    }
}

