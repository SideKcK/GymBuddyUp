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
private let bestRecordRef = ref.child("user_workout_tracking").child(User.currentUser!.userId).child("best_record")

func dateToInt(date: NSDate)->Int {
    
    let timeInterval = date.timeIntervalSince1970
    
    // convert to Integer
    let myInt = Int(timeInterval)
    return myInt
}

func secondToString(second: Int)->String {
    let minute = second/60
    let hour = minute/60
    var minuteStr = String("")
    var hourStr = String("")
    if(minute > 1){
        minuteStr = String(minute) + " minutes"
    }else if(minute > 1){
        minuteStr = String(minute) + " minute"
    }
    if(hour > 1){
        hourStr = String(hour) + " hours"
    }else if(hour > 0){
        hourStr = String(hour) + " hour"
    }
    return hourStr + minuteStr + String(second) + " seconds"
}

class Tracking {
    
    
    init(planId: String) {
        
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
                addBestRecord(trackedItems[index].exercise!,createDate: dateToString(startTime),bestRecord: trackedItems[index].weights.maxElement()!) { (error) in
                    completion(error)
                }
                
            } else if(trackedItems[index].exercise!.unitType == Exercise.UnitType.DurationInSeconds || trackedItems[index].exercise!.unitType == Exercise.UnitType.DistanceInMiles ){
                var set_detail = [String: AnyObject]()
                set_detail["amount"] =  trackedItems[index].finishedAmount
                set_detail["weight"] = 0
                set_details["0"] = set_detail
                addBestRecord(trackedItems[index].exercise!,createDate: dateToString(startTime),bestRecord: trackedItems[index].finishedAmount) { (error) in
                    completion(error)
                }
            } else if(trackedItems[index].exercise!.unitType == Exercise.UnitType.Repetition){
                for index1 in 0 ..< trackedItems[index].reps.count {
                    print("=========== Inside trackedItems[index]"+String(index1))
                    var set_detail = [String: AnyObject]()
                    set_detail["amount"] =  trackedItems[index].reps[index1]
                    set_detail["weight"] = 0
                    set_details[String(index1)] = set_detail
                }
                addBestRecord(trackedItems[index].exercise!,createDate: dateToString(startTime),bestRecord: trackedItems[index].reps.maxElement()!) { (error) in
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
        print("=========== Before getTrackedPlanById!"+id)
        let getTrackedItemGroup = dispatch_group_create()
        trackedPlanRef.child(id).observeSingleEventOfType(.Value,withBlock: {
            (dataSnapshot: FIRDataSnapshot) in
            if let values = dataSnapshot.value as? NSDictionary {
                let result = TrackedPlan(trackingId: id , data: values)
                dispatch_group_enter(getTrackedItemGroup)
                getTrackedItems(dataSnapshot.value as! NSDictionary){(resultTrackedItems, error) in
                    result.trackingItems = resultTrackedItems!
                    dispatch_group_leave(getTrackedItemGroup)
                }
                
                dispatch_group_notify(getTrackedItemGroup, dispatch_get_main_queue()) {
                    print("=========== dispatch_group_notify: ")
                    completion(trackedPlan: result, error: nil)
                }
                
            }else{
                completion(trackedPlan: nil, error: nil)
            }
            
            
        }){
            (error) in
            completion(trackedPlan: nil, error: error)
        }
    }
    
    class func getTrackedItems(data: NSDictionary, completion: (trackedItems: [TrackedItem]?, error: NSError?)-> Void) {
        // Query
        print("=========== Before getTrackedItems!")
        var trackedItems = [TrackedItem]()
        let getTrackedItemGroup = dispatch_group_create()
        //let getTrackedItemGroup = dispatch_group_create()
        let workoutLog = data.valueForKey("workout_log") as? NSArray
        if workoutLog != nil {
        for items in workoutLog! {
            
            var amount = [Int]()
            var weight = [Int]()
            var maxReps = Int()
            var maxWeight = Int()
            var isSkiped = false
            let exerciseData = items as? NSDictionary
            if let set_detail = exerciseData!.valueForKey("set_details") as? NSArray {
                print("=========== index: ")
                for item1 in set_detail {
                    print("=========== index1: ")
                    if(maxReps < (item1.valueForKey("amount") as? Int)!){
                        maxReps = (item1.valueForKey("amount") as? Int)!
                    }
                    if(maxWeight < (item1.valueForKey("weight") as? Int)!){
                        maxWeight = (item1.valueForKey("weight") as? Int)!
                    }
                    amount.append((item1.valueForKey("amount") as? Int)!)
                    weight.append((item1.valueForKey("weight") as? Int)!)
                }
            }
            let exercise_id = (exerciseData!.valueForKey("exercise") as? Int)!
            var exercise : Exercise?
            print("=========== index2: ")
            
            dispatch_group_enter(getTrackedItemGroup)
            Library.getExerciseById(exercise_id){(resultExercise, error) in
                exercise = resultExercise
                print("=========== getExerciseById1: "+String(exercise_id))
                print("=========== getExerciseById2: "+exercise!.name)
                if(exercise == nil){
                    // exercise = Exercise(id: exercise_id,unitType: Exercise.UnitType.RepByWeight)
                }
                if(exercise!.unitType == Exercise.UnitType.RepByWeight){
                    if(maxWeight == 0){
                        isSkiped = true
                    }
                    trackedItems.append(TrackedItem(finishedAmount: 0,finishedSets: 0,exercise: exercise!, reps: amount, weights: weight,  maxReps: maxReps, maxWeight: maxWeight, bestRecordStr: String(maxWeight)+" lbs Max Weight", isSkiped: isSkiped))
                }else if(exercise!.unitType == Exercise.UnitType.DurationInSeconds){
                    if(maxReps == 0){
                        isSkiped = true
                    }
                    trackedItems.append(TrackedItem(finishedAmount: amount[0],finishedSets: 0,exercise: exercise!, reps: amount, weights: weight, maxReps: maxReps, maxWeight: maxWeight, bestRecordStr: secondToString(maxReps), isSkiped: isSkiped))
                }else if(exercise!.unitType == Exercise.UnitType.DistanceInMiles){
                    if(maxReps == 0){
                        isSkiped = true
                    }
                    trackedItems.append(TrackedItem(finishedAmount: amount[0],finishedSets: 0,exercise: exercise!, reps: amount, weights: weight, maxReps: maxReps, maxWeight: maxWeight, bestRecordStr: String(maxReps)+" miles", isSkiped: isSkiped))
                }else if(exercise!.unitType == Exercise.UnitType.Repetition){
                    if(maxReps == 0){
                        isSkiped = true
                    }
                    trackedItems.append(TrackedItem(finishedAmount: 0,finishedSets: 0,exercise: exercise!, reps: amount, weights: weight, maxReps: maxReps, maxWeight: maxWeight, bestRecordStr: String(maxReps) + " Max Reps", isSkiped: isSkiped))
                }
                
                dispatch_group_leave(getTrackedItemGroup)
            }
        }
        dispatch_group_notify(getTrackedItemGroup, dispatch_get_main_queue()) {
            print("=========== dispatch_group_notify: ")
            completion(trackedItems: trackedItems, error: nil)
        }
        }else{
            completion(trackedItems: trackedItems, error: nil)
        }
    }
    
    class func addBestRecord(exercise: Exercise, createDate: String, bestRecord: Int, completion: (NSError?) -> Void) {
        
        var data = [String: AnyObject]()
        
        bestRecordRef.observeSingleEventOfType(.Value,  withBlock: { (snapshot) in
            var bestRecordObj = [String: AnyObject]()
            bestRecordObj["best_record"] = bestRecord
            
            if snapshot.hasChild(String(exercise.id)){
                
                data[createDate] = bestRecordObj
                
                let exerciseBestRecordRef = bestRecordRef.child(String(exercise.id))
                exerciseBestRecordRef.updateChildValues(data) { (error, ref) in
                    completion(error)
                }
                
            }else{
                var subData = [String: AnyObject]()
                subData[createDate] = bestRecordObj
                data[String(exercise.id)] = subData
                bestRecordRef.updateChildValues(data) { (error, ref) in
                    completion(error)
                }
            }
            
        })
    }
    
    class func getBestRecordByExercise(exercise: Exercise, complete: (BestRecord)-> Void) {
        // Query
        print("=========== Before getBestRecordByExercise!"+String(exercise.id))
        if(exercise.unitType == Exercise.UnitType.Repetition || exercise.unitType == Exercise.UnitType.DurationInSeconds  || exercise.unitType == Exercise.UnitType.DistanceInMiles  || exercise.unitType == Exercise.UnitType.RepByWeight){
            bestRecordRef.child(String(exercise.id)).queryOrderedByChild("best_record").queryLimitedToLast(1).observeSingleEventOfType(.Value) { (dataSnapshot: FIRDataSnapshot) in
                let dataDict = (dataSnapshot.value as? NSDictionary)
                for(key, value) in dataDict!{
                    print("=========== Before getBestRecordByExercise!"+(key as! String))
                    let result = BestRecord(exerciseId: exercise.id ,createDate: key as! String, dict:(value as! NSDictionary))
                    complete(result)
                }
            }
        }
    }
    
    class func getTrackedPlanTimeSpan(startDate: NSDate, endDate: NSDate, completion: (trackedPlan: [TrackedPlan]?, error: NSError?)-> Void) {
        // Query
        print("=========== Before getTrackedPlanTimeSpan!")

        trackedPlanRef.queryOrderedByChild("start_time").queryStartingAtValue(dateToInt(startDate))
            .queryEndingAtValue(dateToInt(endDate)).observeSingleEventOfType(.Value) { (dataSnapshot: FIRDataSnapshot) in
                var results:[TrackedPlan] = []
                
                let trackedPlans = (dataSnapshot.value as? NSDictionary)
                if(trackedPlans != nil){
                    let myGroup = dispatch_group_create()
                    for(key,value) in trackedPlans!{
                        let result = TrackedPlan(trackingId: key as! String , data:(value as! NSDictionary))
                        /*getTrackedItems(dataSnapshot.value as! NSDictionary){(resultTrackedItems, error) in
                            result.trackingItems = resultTrackedItems!
                        }*/
                         //print("=========== inside getTrackedPlanTimeSpan!" +  result.planId!)
                        
                        dispatch_group_enter(myGroup)
                        Library.getPlanById(result.planId!, completion: { (plan, error) in
                            
                            if error != nil {
                                //print("error getting plan for \(result.planId!)")
                            }
                            else {
                                if plan != nil{
                                    //print("=========== inside getPlanById!" + (plan?.name)!)
                                    result.plan = plan!
                                    results.append(result)
                                }
                            }
                            
                            dispatch_group_leave(myGroup)
                        })
                        
                        
                    }
                    dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
                         //print("=========== end of getTrackedPlanTimeSpan")
                        completion(trackedPlan: results, error: nil)
                    })
                    
                }else{
                    results = [TrackedPlan]()
                    completion(trackedPlan: results, error: nil)
                }
                
        }
    }
    
    class func getIsTrackedById(workoutids: [String], completion: (isTracked: [Bool]?, error: NSError?)-> Void) {
        // Query
        
        
        if workoutids.count == 0 {
            return completion(isTracked: [], error: nil)
        }
        
        let myGroup = dispatch_group_create()
        let numPlan = workoutids.count
        var isTrackeds = [Bool](count: numPlan, repeatedValue: Bool(false))
        
        for (index, id) in workoutids.enumerate() {
            dispatch_group_enter(myGroup)
            trackedPlanRef.child(id).observeSingleEventOfType(.Value,withBlock: {
                (dataSnapshot: FIRDataSnapshot) in
                if let values = dataSnapshot.value as? NSDictionary {
                    isTrackeds[index] = true
                }else{
                    isTrackeds[index] = false
                }
                 dispatch_group_leave(myGroup)
                
            }){
                (error) in
                completion(isTracked: [], error: error)
            }
        }
        
        dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
            completion(isTracked: isTrackeds, error: nil)
        })
        
    }
}



