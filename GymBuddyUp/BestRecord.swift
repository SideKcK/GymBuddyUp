//
//  BestRecord.swift
//  GymBuddyUp
//
//  Created by lingchao kong on 16/8/19.
//  Copyright © 2016年 You Wu. All rights reserved.
//
//

import Foundation
import CoreLocation

import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftDate

private let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
private let bestRecordRef = ref.child("user_workout_tracking").child(User.currentUser!.userId).child("best_record")

class BestRecord{
    var exerciseId: Int!
    var createDate:String?
    var bestRecord:Int!
    
    init (exerciseId: Int, createDate:String , dict: NSDictionary) {
        self.exerciseId = exerciseId
        self.createDate = createDate
        self.bestRecord = dict.valueForKey("best_record") as? Int
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
}




