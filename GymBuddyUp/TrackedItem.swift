//
//  TrackingItem.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/17/16.
//  Copyright © 2016 Yi Huang. All rights reserved.
//

import UIKit
import CoreLocation

import Firebase
import FirebaseDatabase
import FirebaseStorage

/*
 exercise type:
    case Repetition = 0
    case DurationInSeconds = 1
    case DistanceInMiles = 2
    case RepByWeight = 3
 
*/


class TrackedItem {
    var finishedAmount: Int
    var finishedSets: Int
    var exercise: Exercise?
    var maxReps: Int
    var maxWeight: Int
    
    init(_exercise: Exercise) {
        exercise = _exercise
        finishedAmount = 0
        finishedSets = 0
        maxReps = 0
        maxWeight = 0
    }
    
    func saveOnNextExercise(_finishedAmount: Int, _finishedSets: Int) {
        finishedAmount = _finishedAmount
        finishedSets = _finishedSets
    }
    
    func saveOnNextSet(reps: Int, weight: Int) {
        finishedSets += 1
        maxReps = max(reps, maxReps)
        maxWeight = max(weight, maxWeight)
    }
    
    func getDict() -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict["exerciseId"] = exercise?.id
        dict["finishedAmount"] = finishedAmount
        dict["finishedSets"] = finishedSets
        dict["maxReps"] = maxReps
        dict["maxWeight"] = maxWeight
        return dict
    }
}