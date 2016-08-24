//
//  Discover.swift
//  GymBuddyUp
//
//  Created by Wei Wang on 8/21/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftDate
import Alamofire

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
private let publishedWorkoutRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout")
private let publishedWorkoutLocationRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout_location")

struct PublishedWorkout {
    var id: String
    var planId: String
    var gymLocation: CLLocation
    var gymPlaceId: String?
    var publishedBy: String
    var workoutTime: NSDate
    var publishedAt: NSDate
    
    init (id: String, location: CLLocation, dict: NSDictionary) {
        self.id = id
        self.gymLocation = location
        self.planId = dict.valueForKey("plan") as! String
        self.gymPlaceId = dict.valueForKey("gym_place_id") as? String
        self.publishedBy = dict.valueForKey("published_by") as! String
        
        let workoutTime = dict.valueForKey("workout_time") as! Double
        self.workoutTime = NSDate(timeIntervalSince1970: workoutTime)
        
        let publishedAt = dict.valueForKey("published_at") as! Double
        self.publishedAt = NSDate(timeIntervalSince1970: publishedAt)
    }
}

class Discover {
    
    class func discoverPublicWorkout(location: CLLocation, radiusInkilometers: Double, withinDays: Int, offset: Int?, completion: ([PublishedWorkout], NSError?) -> Void) {
        // Query locations at input location with a radius of radius meters
        
        var result = [PublishedWorkout]()
        
        let geoQueryDispatchGroup = dispatch_group_create()
        
        // 今天不排序先。。。
        
        
        for i in (0 ..< withinDays)
        {
            dispatch_group_enter(geoQueryDispatchGroup)

            let date = (NSDate() + i.days).toString(DateFormat.Custom("yyyy-MM-dd"))
            print("DISCOVERING EVENTS for \(date!)")
            
            let geofire = GeoFire(firebaseRef: publishedWorkoutLocationRef.child(date!))
            let query = geofire.queryAtLocation(location, withRadius: radiusInkilometers)
            
            let fetchWorkoutDispatchGroup = dispatch_group_create()
            
            let observerHandle = query.observeEventType(.KeyEntered, withBlock: { (key: String!, foundLocation: CLLocation!) in
                //print(key, location.distanceFromLocation(foundLocation))
                dispatch_group_enter(fetchWorkoutDispatchGroup)
                
                publishedWorkoutRef.child(key).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    let data = snapshot.value as! [String:AnyObject]
                    result.append(PublishedWorkout(id: key, location: foundLocation, dict: data))
                    dispatch_group_leave(fetchWorkoutDispatchGroup)
                })
            })
            
            query.observeReadyWithBlock({
                query.removeObserverWithFirebaseHandle(observerHandle)
                dispatch_group_notify(fetchWorkoutDispatchGroup, dispatch_get_main_queue()) {
                    dispatch_group_leave(geoQueryDispatchGroup)
                }
            })
        }
        
        dispatch_group_notify(geoQueryDispatchGroup, dispatch_get_main_queue()) {
            print(result.count, "results found")
            completion(result, nil)
        }
    }
}