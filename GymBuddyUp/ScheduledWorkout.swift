//
//  ScheduledWorkout.swift
//  GymBuddyUp
//
//  Created by Wei Wang on 8/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation
import CoreLocation

import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftDate

private let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
private let workoutCalendarRef = ref.child("user_workout_calendar").child(User.currentUser!.userId)



func dateToString(date: NSDate)->String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.stringFromDate(date)
    return dateString
}

func stringToDate(dateString: String)->NSDate? {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.dateFromString(dateString)
    return date
}

func daysBetweenDates(startDate: NSDate, endDate: NSDate) -> Int
{
    let calendar = NSCalendar.currentCalendar()
    
    let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
    
    return components.day
}

class ScheduledWorkout {
    var id : String
    var startDate : NSDate
    var endDate: NSDate?
    var recur: Int
    var planId: String
    var skipOn: [NSDate]
    
    init(id:String, data: NSDictionary)
    {
        self.id = id
        self.startDate = stringToDate(data.valueForKey("start_date") as! String)!
        self.endDate = stringToDate(data.valueForKey("end_date") as! String)
        self.recur = data.valueForKey("repeat") as! Int
        self.planId = data.valueForKey("plan") as! String
        
        let skipOn = data.valueForKey("skip_on") as? NSDictionary
        if skipOn != nil {
            self.skipOn = (skipOn!.allKeys as! [String]).map({ (dateString) -> NSDate in
                stringToDate(dateString)!
            })
        }
        else {
            self.skipOn = []
        }
    }
    
    class func initFromQueryResults(queryResults: NSDictionary?) -> [ScheduledWorkout]
    {
        if queryResults != nil {
            
            var workoutArray = [ScheduledWorkout]()
            for id in queryResults!.allKeys
            {
                let data = queryResults![id as! String] as! NSDictionary
                workoutArray.append(ScheduledWorkout(id: id as! String, data: data))
            }
            return workoutArray
        }
        
        else
        {
            return []
        }
    }
    
    class func isDateInArray(date: NSDate, dateArray: [NSDate]) -> Bool {
        for element in dateArray {
            if date.isInSameDayAsDate(element) {
                return true
            }
        }
        
        return false
    }
    
    //assign this plan as user's today plan
    //replace if plan exists
    
    class func addWorkoutToCalendar(planId: String, startDate: NSDate, endDate: NSDate? = stringToDate("9999-12-31"), recur: Int = 0, completion: (NSError?) -> Void) {
        let planId = planId
        let newWorkoutRef = workoutCalendarRef.childByAutoId()
        
        var data = [String: AnyObject]()
        data["plan"] = planId
        data["repeat"] = recur
        data["skip_on"] = nil
        data["created"] = FIRServerValue.timestamp()
        data["start_date"] = dateToString(startDate)
        data["end_date"] = recur > 0 ? dateToString(endDate!) : data["start_date"]
        // If workout is not recurring, set end_date same as start_date, else use specified end_date. if specified enddate is nil, use 9999-12-31.
        
        newWorkoutRef.setValue(data) { (error, ref) in
            if (error != nil) {
                print(error)
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    class func skipScheduledWorkoutForDate(scheduledWorkoutId: String, date: NSDate, completion: (NSError?) -> Void) {
        let workoutRef = workoutCalendarRef.child(scheduledWorkoutId).child("skip_on").child(dateToString(date))
        workoutRef.setValue(true) { (error, ref) in
            if (error != nil) {
                completion(nil)
            }
        }
    }
    
    
    class func deleteScheduledWorkout(scheduledWorkoutId: String, completion: (NSError?) -> Void) {
        let workoutRef = workoutCalendarRef.child(scheduledWorkoutId).child("repeat")
        workoutRef.setValue(-1) { (error, ref) in
        completion(error)
        }
    }

    class func stopRecurringWorkoutOnDate(scheduledWorkoutId: String, stopOnDate: NSDate, completion: (NSError?) -> Void) {
        let workoutRef = workoutCalendarRef.child(scheduledWorkoutId).child("end_date")
        workoutRef.setValue(dateToString(stopOnDate)) { (error, ref) in
        completion(error)
        }
    }
    
    /**
     Get all scheduled workouts that are active on the date. (Not necessarily scheduled for that date. A workout will be counted as active as long as it didn't stop before the date.)
     */
    private class func getActiveWorkoutsForDate(date: NSDate, complete: ([ScheduledWorkout])-> Void) {
        // Query
        workoutCalendarRef.queryOrderedByChild("end_date").queryStartingAtValue(dateToString(date)).observeSingleEventOfType(.Value) { (dataSnapshot: FIRDataSnapshot) in
                let results = initFromQueryResults(dataSnapshot.value as? NSDictionary)
                complete(results)
        }
        
    }
    
    /**
     Get all workouts that are scheduled on the date. (for now there will only be 1 workout for a day. but still returns a list. )
     */
    class func getScheduledWorkoutsForDate(date: NSDate, complete: ([ScheduledWorkout])-> Void) {
        // Query
        getActiveWorkoutsForDate(date) {(workouts) in
            var results = [ScheduledWorkout]()
            for workout in workouts {
                if workout.startDate.isInSameDayAsDate(date) && workout.recur >= 0 {
                    results.append(workout)
                }
                    
                else if workout.startDate < date
                    &&  workout.recur > 0
                    && !isDateInArray(date, dateArray: workout.skipOn)
                    && daysBetweenDates(workout.startDate, endDate:date) % workout.recur == 0
                
                {
                    results.append(workout)
                }
            }
            
            complete(results)
        }
    }
}
