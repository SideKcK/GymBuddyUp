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
private let exerciseRef = ref.child("exercise")
private let planDetailRef = ref.child("plan_detail")
private let gymMidCategoryRef = ref.child("gym_mid_category")
private let systemPlanRef = ref.child("system_plan")

class SysData {
    
    
    init(planId: String) {
        
    }
    
    class func addExerciseRecord(jsonString: String, completion: (NSError?) -> Void) {
        
        var data = [String: AnyObject]()
        convertStringToArray(jsonString){(dictionary) in
            data = dictionary
        }
        
        exerciseRef.updateChildValues(data) { (error, ref) in
            print("=========== Inside addExerciseRecord!")
            completion(error)
        }

    }
    
    class func addGymMidCategoryRecord(jsonString: String, completion: (NSError?) -> Void) {
        
        var data = [String: AnyObject]()
        convertStringToArray(jsonString){(dictionary) in
            data = dictionary
        }
        
        gymMidCategoryRef.updateChildValues(data) { (error, ref) in
            print("=========== Inside addExerciseRecord!")
            completion(error)
        }
        
    }
    class func addSysPlanRecord(jsonString: String, jongString_detail: String, completion: (NSError?) -> Void) {
        let newWorkoutRef = systemPlanRef.childByAutoId()
        var data = [String: AnyObject]()
        let getPlanDetailGroup = dispatch_group_create()
        let planId = newWorkoutRef.key
        print("=========== planId"+planId)
        convertStringToArray(jsonString){(dictionary) in
            data = dictionary
        }
        dispatch_group_enter(getPlanDetailGroup)
        newWorkoutRef.updateChildValues(data) { (error, ref) in
            print("=========== Inside addExerciseRecord!")
            dispatch_group_leave(getPlanDetailGroup)
            var data_detail = [String: AnyObject]()
            let jongString_detail1 = "{ \""+planId+"\" : "+jongString_detail+" }"
            convertStringToArray(jongString_detail1){(dictionary) in
                data_detail = dictionary
            }
            planDetailRef.updateChildValues(data_detail) { (error, ref) in
                print("=========== Inside addExerciseRecord!")
                completion(error)
            }
        }
        
        dispatch_group_notify(getPlanDetailGroup, dispatch_get_main_queue()) {
            print("=========== dispatch_group_notify: ")
            
        }
        
        
    }
    
    class func addPlanDetailRecord(jsonString: String,completion: (NSError?) -> Void) {
        var data_detail = [String: AnyObject]()
        convertStringToArray(jsonString){(dictionary) in
            data_detail = dictionary
        }
        planDetailRef.updateChildValues(data_detail) { (error, ref) in
            print("=========== Inside addPlanDetailRecord!")
            completion(error)
        }
        
    }
    class func convertStringToArray(jsonString: String, complete: ([String: AnyObject])-> Void){
        print("=========== Before convertStringToDictionary!")

        do {
            if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
                // With value as AnyObject
                if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject] {
                    complete(json)
                }
            }
        } catch {
            print(error)
        }
        
    }
}

