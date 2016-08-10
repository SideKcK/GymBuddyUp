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

private let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
private let workoutCalendar = ref.child("user_workout_calendar")


struct Gym {
    var name: String
    var placeId : String
    var latlong: CLLocation
    var address: CLPlacemark
}


struct ScheduledWorkout {
    var id : String
    var startDate : NSDate
    var endDate: NSDate?
    var recur: Int
    var planId: String
    var skipOn: [NSDate]?
    
}


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

    //assign this plan as user's today plan
    //replace if plan exists
    
    class func addWorkoutToCalendar(planId: String, startDate: NSDate, endDate:NSDate? = nil, recur: Int = 0, completion: (NSError?) -> Void) {
        let planId = planId
        let newWorkoutRef = workoutCalendar.child(User.currentUser!.userId).childByAutoId()
        
        var data = [String: AnyObject]()
        data["plan"] = planId
        data["repeat"] = recur
        data["skip_on"] = nil
        data["created"] = FIRServerValue.timestamp()
        data["start_date"] = formatDate(startDate)
        data["end_date"] = endDate != nil ? formatDate(endDate!):nil
        
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
    
    
    class func deleteScheduledWorkoutForDate(scheduledWorkoutId: String, date: NSDate, repeatPlan: Bool, completion: (NSError?)) -> Void {
        let workoutRef = workoutCalendar.child(User.currentUser!.userId).child(scheduledWorkoutId).child("skip_on")
        workoutRef.setValue(true, forKey: formatDate(date))
    }
    
    class func stopRecurringWorkout(planId: String, stopOnDate: NSDate, completion: (NSError?)) -> Void {
        let workoutRef = workoutCalendar.child(User.currentUser!.userId).child(planId)
        workoutRef.setValue(formatDate(stopOnDate), forKey: "end_date")
    }
    
    class func getScheduledWorkoutForDate(date: NSDate) {
        
    }
    
    
    class func getActiveScheduledWorkouts () {
        
    }
    
    
    static func formatDate(date: NSDate)->String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
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