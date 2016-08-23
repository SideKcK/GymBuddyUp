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
    var setsAmount: Int
    var finishedAmount: Int // for timed sensitive item like running
    var finishedSets: Int   // for mechanical item like pressing
    var exercise: Exercise? // reference for Exercise
    var maxReps: Int
    var maxWeight: Int
    var isFinalized: Bool
    var reps: [Int]
    var weights: [Int]
    
    // TODO: read set from exercise
    init(_exercise: Exercise) {
        setsAmount = 3
        exercise = _exercise
//        need to set setsAmount
//        setsAmount = exercise.set
        finishedAmount = 0
        finishedSets = 0
        maxReps = 0
        maxWeight = 0
        isFinalized = false
        reps = [Int](count: setsAmount, repeatedValue: 0)
        weights = [Int](count: setsAmount, repeatedValue: 0)
    }
    
    func saveOnNextExercise(onFinishedAmount: Int, onFinishedSets: Int) {
        finishedAmount = onFinishedAmount
        finishedSets = onFinishedSets
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