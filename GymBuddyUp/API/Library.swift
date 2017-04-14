//
//  Library.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

private let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
private let storageRef = FIRStorage.storage().reference()

private let midCategoryRef = ref.child("gym_mid_category")
private let exerciseRef = ref.child("exercise")
private let systemPlanRef = ref.child("system_plan")
private let planDetailRef = ref.child("plan_detail")


class Library {

    class func getMidCategory(completion: (content:[MidCat]?, error:NSError?) -> Void) {
        midCategoryRef.observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            let value = snapshot.valueInExportFormat() as? NSDictionary
            let entries = value?.allValues as? [NSDictionary]

            let cats = MidCat.catsWithArray(entries)
            completion(content: cats, error: nil)

        }) {
            (error) in
            completion(content: nil, error: error)
        }
    }
    
    class func getPlanById(planId: String, completion: (plan: Plan?, error: NSError?) -> Void ) {
        systemPlanRef.child(planId).observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            if let jsonData = snapshot.value as? NSDictionary {
                
                getExercisesByPlanId(planId, completion: { (exercises, error) in
                    
                    if (error != nil) {
                        return completion(plan: nil, error: error)
                    }
                    
                    let plan = Plan(id: planId, dict: jsonData, exercises: exercises)
                    completion(plan: plan, error: nil)
                })
            }
        }) {
            (error) in
            completion(plan: nil, error: error)
        }
    }
    

    class func getPlansByMidId(catID: Int, completion: (plans:[Plan]?, error:NSError?) -> Void) {
        midCategoryRef.child("\(catID)/system_plans").observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            var plans = [Plan]()
            let getPlanTaskGrp = dispatch_group_create()
            
            for planSnapshot in snapshot.children {
                let planId = (planSnapshot as! FIRDataSnapshot).key
                let status =  (planSnapshot as! FIRDataSnapshot).value as! Bool
                if  status == true{
                    dispatch_group_enter(getPlanTaskGrp)
                    getPlanById(planId, completion: { (plan, error) in
                        if let plan = plan {
                            print("getting plan", planId)
                            plans.append(plan)
                            dispatch_group_leave(getPlanTaskGrp)
                        }
                    })
                }
            }
            
            dispatch_group_notify(getPlanTaskGrp, dispatch_get_main_queue()) {
                completion(plans: plans, error: nil)
            }

        }) {
            (error) in
            completion(plans: nil, error: error)
        }
    }
    
    class func getSinglePlanByMidId(catID: Int, completion: (plans: Plan?, error:NSError?) -> Void) {
        print("getSinglePlanByMidId " + String(catID))
        
        var plan = Plan()
        midCategoryRef.child("\(catID)/system_plans").observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            
            let getPlanTaskGrp1 = dispatch_group_create()
            
            for planSnapshot in snapshot.children {
                let planId = (planSnapshot as! FIRDataSnapshot).key
                print("inside getSinglePlanByMidId " + planId)
                dispatch_group_enter(getPlanTaskGrp1)
                
                if let isMultiple = (planSnapshot as! FIRDataSnapshot).value as? Bool {
                    if(!isMultiple){
                    getPlanById(planId, completion: { (_plan, error) in
                        if _plan != nil {
                            print("getting plan", planId)
                            plan = _plan!
                            dispatch_group_leave(getPlanTaskGrp1)
                        }else{
                            dispatch_group_leave(getPlanTaskGrp1)
                        }
                    })
                        
                    }else{
                        dispatch_group_leave(getPlanTaskGrp1)
                    }
                }else{
                     dispatch_group_leave(getPlanTaskGrp1)
                }
               
            }
            
            dispatch_group_notify(getPlanTaskGrp1, dispatch_get_main_queue()) {
                print("leave getPlanTaskGrp1")
                completion(plans: plan, error: nil)
            }
            
        }) {
            (error) in
            completion(plans: nil, error: error)
        }
        
    }
    
    private class func getExercisesByPlanId(planId: String, completion: (exercises: [Exercise]?, error: NSError?) -> Void)  {
        planDetailRef.child(planId).observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            
            var exercises = [Exercise]()
            let getExercisesTaskGroup = dispatch_group_create()
            
            for exerciseSnapshot in snapshot.children {
                let exerciseSnapshot = exerciseSnapshot as! FIRDataSnapshot
                let exerciseData = exerciseSnapshot.value as? NSDictionary
                
                let exerciseId = exerciseData?.valueForKey("exercise") as? Int
                let setData = exerciseData?.valueForKey("set") as? [NSDictionary]
                
                if (exerciseId != nil) {
                    dispatch_group_enter(getExercisesTaskGroup)
                    getExerciseById(exerciseId!,completion: { (exercise, error) in
                        if let exercise = exercise {
                            
                            exercise.set = Exercise.Set.setArrayFromDictArray(setData)
                            exercises.append(exercise)
                            dispatch_group_leave(getExercisesTaskGroup)
                        }
                        else {
                            print("error getting exercise by plan id", error)
                            dispatch_group_leave(getExercisesTaskGroup)
                        }
                    })
                }
            }
            
            dispatch_group_notify(getExercisesTaskGroup, dispatch_get_main_queue()) {
                completion(exercises: exercises, error: nil)
            }
            
        }) {
            (error) in
            completion(exercises: nil, error: error)
        }
    }
    
    class func getExerciseById(exerciseId: Int, completion: (exercise: Exercise?, error: NSError?) -> Void ) {
        exerciseRef.child(String(exerciseId)).observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            if let jsonData = snapshot.value as? NSDictionary {
                let exercise = Exercise(id: exerciseId, dict: jsonData);
                completion(exercise: exercise, error: nil)
            }
        }) {
            (error) in
            completion(exercise: nil, error: error)
        }
    }
    
    // Problemetic
    class func getPlansById (planId: [String], completion: (plans: [Plan], error: NSError?) -> Void) {
        
        if planId.count == 0 {
            return completion(plans: [], error: nil)
        }
        
        let myGroup = dispatch_group_create()
        let numPlan = planId.count
        var plans = [Plan](count: numPlan, repeatedValue: Plan())
        
        for (index, id) in planId.enumerate() {
            dispatch_group_enter(myGroup)
            Library.getPlanById(id, completion: { (plan, error) in
                if error != nil {
                    print("error getting plan for \(id)")
                }
                else {
                    plans[index] = plan!
                }
                
                dispatch_group_leave(myGroup)
            })
        }
        
        dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
            completion(plans: plans, error: nil)
        })
    }
}