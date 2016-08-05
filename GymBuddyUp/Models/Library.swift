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

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
private let storageRef = FIRStorage.storage().reference()

private let topCategoryRef = ref.child("gym_top_category")
private let midCategoryRef = ref.child("gym_mid_category")
private let subCategoryRef = ref.child("gym_sub_category")


class Library {
    
    class func getPlansById(catID: String, completion: (plans: [Plan], error: NSError?) -> Void) {
        var dictArray = [NSDictionary]()
        //TODO: get [NSDictionary]
        
        //let plans = Plan.plansWithArray(dictArray)
        let plans = [Plan(), Plan()]
        completion(plans: plans, error: nil)
    }
    
    class func getExerciseById(planId: String, completion: (exers: [Exercise], error: NSError?) -> Void) {
        var dictArray = [NSDictionary]()
        //TODO: get [NSDictionary]
        
        let exers = Exercise.exersWithArray(dictArray)
        completion(exers: exers, error: nil)
    }
    
    class func getTopCategory(completion: (content: [NSDictionary]?, error: NSError?) -> Void) {
        topCategoryRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let value = snapshot.valueInExportFormat() as? NSDictionary
            let entries = value?.allValues as? [NSDictionary]
            
            completion(content: entries, error: nil)
            
        }) { (error) in
            completion(content: nil, error: error)
        }
    }
    
    class func getMidCategory(completion: (content: [MidCat]?, error: NSError?) -> Void) {
        midCategoryRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let value = snapshot.valueInExportFormat() as? NSDictionary
            let entries = value?.allValues as? [NSDictionary]
                let cats = MidCat.catsWithArray(entries)
                completion(content: cats, error: nil)
            
        }) { (error) in
            completion(content: nil, error: error)
        }
    }
    
    class func getSubCategory(completion: (content: [NSDictionary]?, error: NSError?) -> Void) {
        subCategoryRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let value = snapshot.valueInExportFormat() as? NSDictionary
            let entries = value?.allValues as? [NSDictionary]
            
            completion(content: entries, error: nil)
            
        }) { (error) in
            completion(content: nil, error: error)
        }
    }
}


