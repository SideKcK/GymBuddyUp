//
//  ExtensionsAPI.swift
//  GymBuddyUp
//
//  Created by you wu on 8/16/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

extension Library {
    class func getPlansById (planId: [String], completion: (plans: [Plan]?, error: NSError?) -> Void) {
        let myGroup = dispatch_group_create()
        var plans = [Plan]()
        for id in planId {
            dispatch_group_enter(myGroup)
            Library.getPlanById(id, completion: { (plan, error) in
                guard let plan = plan else {
                    print(error)
                    completion(plans: nil, error: error)
                    return
                }
                Library.getExercisesByPlanId(id, completion: { (exercises, error) in
                    if error == nil {
                        plan.exercises = exercises
                        plans.append(plan)
                        dispatch_group_leave(myGroup)
                    }else {
                        print(error)
                        completion(plans: nil, error: error)
                    }
                })
                
            })
        }
        
        dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
            print("get plans by ids: Finished all requests.")
            completion(plans: plans, error: nil)
        })
        
    }
    
}

extension ScheduledWorkout {
    class func getScheduledWorkoutsInRange(startDate: NSDate, endDate: NSDate, completion: (workouts:[NSDate: [ScheduledWorkout]]?, error: NSError?) -> Void) {
        let dateRange = DateRange(calendar: NSCalendar.currentCalendar(),
                                  startDate: startDate,
                                  endDate: endDate,
                                  stepUnits: NSCalendarUnit.Day,
                                  stepValue: 1)
        let myGroup = dispatch_group_create()
        var allworkouts = [NSDate: [ScheduledWorkout]]()
        for date in dateRange {
            dispatch_group_enter(myGroup)
            ScheduledWorkout.getScheduledWorkoutsForDate(date) { (workouts) in
                allworkouts[date] = workouts
                dispatch_group_leave(myGroup)
            }
            
        }
        dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
            print("get workouts in range: Finished all requests.")
            completion(workouts: allworkouts, error: nil)
        })

    }
}