//
//  Tracking.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/17/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation

import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftDate

private let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
private let trackedPlanRef = ref.child("user_workout_tracking").child(User.currentUser!.userId)

func dateToInt(date: NSDate)->Int {
    
    let timeInterval = date.timeIntervalSince1970
    
    // convert to Integer
    let myInt = Int(timeInterval)
    return myInt
}

class TrackedPlan {
    weak var plan: Plan?
    var planId: String?
    var trackingId: String? //format  is  “eventId:date”
    var startDate : NSDate?
    var endDate: NSDate?
    var user: User?
    var scheduledWorkout: String?
    var trackingItems = [TrackedItem]()
    
    init(plan: Plan) {
     self.plan = plan
     if let exercises = plan.exercises {
     //Log.info("if let exercises = plan.exercises {")
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
        }
            
        else
        {
            return []
        }
    }
    
    
    func saveToBackend() {
        
    }
    
    class func trackedPlanOnSave(scheduledWorkout: String, planId: String, startTime: NSDate, endTime: NSDate, trackedItems: [TrackedItem],
                                 completion: (NSError?) -> Void) {
        
        print("=========== Inside trackedPlanOnSave"+User.currentUser!.userId)
        var data = [String: AnyObject]()
        var subdata = [String: AnyObject]()
        var workoutLog = [String: AnyObject]()

        subdata["plan_id"] = planId
        subdata["scheduled_workout"] = scheduledWorkout
        subdata["start_time"] = dateToInt(startTime)
        subdata["end_time"] = dateToInt(endTime)
        
        for index in 0 ..< trackedItems.count {
            print("=========== Inside trackedItems"+String(index))
            var exercise_details = [String: AnyObject]()
            exercise_details["exercise"] =  trackedItems[index].exercise!.id
            var set_details = [String: AnyObject]()
            if(trackedItems[index].exercise!.unitType == Exercise.UnitType.RepByWeight){
                for index1 in 0 ..< trackedItems[index].reps.count {
                    print("=========== Inside trackedItems[index]"+String(index1))
                    var set_detail = [String: AnyObject]()
                    set_detail["amount"] =  trackedItems[index].reps[index1]
                    set_detail["weight"] =  trackedItems[index].weights[index1]
                    set_details[String(index1)] = set_detail
                    
                    
                }
                BestRecord.addBestRecord(trackedItems[index].exercise!,createDate: dateToString(startTime),bestRecord: trackedItems[index].weights.maxElement()!) { (error) in
                    completion(error)
                }

            }else if(trackedItems[index].exercise!.unitType == Exercise.UnitType.DurationInSeconds || trackedItems[index].exercise!.unitType == Exercise.UnitType.DistanceInMiles ){
                var set_detail = [String: AnyObject]()
                set_detail["amount"] =  trackedItems[index].finishedAmount
                set_detail["weight"] = 0
                set_details["0"] = set_detail
                BestRecord.addBestRecord(trackedItems[index].exercise!,createDate: dateToString(startTime),bestRecord: trackedItems[index].finishedAmount) { (error) in
                    completion(error)
                }
            }else if(trackedItems[index].exercise!.unitType == Exercise.UnitType.Repetition){
                for index1 in 0 ..< trackedItems[index].reps.count {
                    print("=========== Inside trackedItems[index]"+String(index1))
                    var set_detail = [String: AnyObject]()
                    set_detail["amount"] =  trackedItems[index].reps[index1]
                    set_detail["weight"] = 0
                    set_details[String(index1)] = set_detail
                }
                BestRecord.addBestRecord(trackedItems[index].exercise!,createDate: dateToString(startTime),bestRecord: trackedItems[index].reps.maxElement()!) { (error) in
                    completion(error)
                }
            }
            exercise_details["set_details"] =  set_details
            workoutLog[String(index)] = exercise_details
        }
        subdata["workout_log"] = workoutLog
        data[scheduledWorkout+":"+dateToString(startTime)] = subdata
        
        trackedPlanRef.updateChildValues(data) { (error, ref) in
            completion(error)
        }
    }
    
    
    /**
     Get all tracking info by specified date
     */
    class func getTrackedPlanByDate(date: NSDate, completion: (trackedPlan: [TrackedPlan]?, error: NSError?)-> Void) {
        // Query
        print("=========== Before getTrackedPlanByDate!")
        let interval = NSTimeInterval(60 * 60 * 24 * 1)
        let newDate = date.dateByAddingTimeInterval(interval)
        trackedPlanRef.queryOrderedByChild("start_date").queryStartingAtValue(dateToString(date))
            .queryEndingAtValue(dateToString(newDate)).observeSingleEventOfType(.Value) { (dataSnapshot: FIRDataSnapshot) in
                var results:[TrackedPlan]?
                
                let trackedPlans = (dataSnapshot.value as? NSDictionary)
                if(trackedPlans != nil){
                    for(key,value) in trackedPlans!{
                        let result = TrackedPlan(trackingId: key as! String , data:(value as! NSDictionary))
                        getTrackedItems(dataSnapshot.value as! NSDictionary){(resultTrackedItems, error) in
                            result.trackingItems = resultTrackedItems!
                        }
                        results?.append(result)
                    }
                }else{
                    results = [TrackedPlan]()
                }
                completion(trackedPlan: results, error: nil)
        }
    }
    
    /**
     Get all tracking info by specified date
     */
    class func getTrackedPlanById(id: String, completion: (trackedPlan: TrackedPlan?, error: NSError?)-> Void) {
        // Query
        print("=========== Before getTrackedPlanById!")
        
        trackedPlanRef.child(id).observeSingleEventOfType(.Value,withBlock: {
            (dataSnapshot: FIRDataSnapshot) in
            let result = TrackedPlan(trackingId: id , data:(dataSnapshot.value as! NSDictionary))
            getTrackedItems(dataSnapshot.value as! NSDictionary){(resultTrackedItems, error) in
                result.trackingItems = resultTrackedItems!
            }
            completion(trackedPlan: result, error: nil)
        }){
            (error) in
            completion(trackedPlan: nil, error: error)
        }
    }
    
    class func getTrackedItems(data: NSDictionary, completion: (trackedItems: [TrackedItem]?, error: NSError?)-> Void) {
        // Query
        print("=========== Before getTrackedItems!")
        var trackedItems = [TrackedItem]()
        let getExercisesTaskGroup = dispatch_group_create()
        //let getTrackedItemGroup = dispatch_group_create()
        let workoutLog = data.valueForKey("workout_log") as? NSArray
        for items in workoutLog! {
            
            var amount = [Int]()
            var weight = [Int]()
            let exerciseData = items as? NSDictionary
            let set_detail = exerciseData!.valueForKey("set_details") as? NSArray
            print("=========== index: ")
            for item1 in set_detail! {
                print("=========== index1: ")
                
                amount.append((item1.valueForKey("amount") as? Int)!)
                weight.append((item1.valueForKey("weight") as? Int)!)
            }
            let exercise_id = (exerciseData!.valueForKey("exercise") as? Int)!
            var exercise : Exercise?
            print("=========== index2: ")
            dispatch_group_enter(getExercisesTaskGroup)
            Library.getExerciseById(exercise_id){(resultExercise, error) in
                exercise = resultExercise
                print("=========== getExerciseById1: "+String(exercise_id))
                print("=========== getExerciseById2: "+exercise!.name)
                if(exercise == nil){
                   // exercise = Exercise(id: exercise_id,unitType: Exercise.UnitType.RepByWeight)
                }
                trackedItems.append(TrackedItem(finishedAmount: 0,finishedSets: 0,exercise: exercise!, reps: amount, weights: weight))
                dispatch_group_leave(getExercisesTaskGroup)
            }
        }
        dispatch_group_notify(getExercisesTaskGroup, dispatch_get_main_queue()) {
            print("=========== dispatch_group_notify: ")
            completion(trackedItems: trackedItems, error: nil)
        }
    }
    
}

