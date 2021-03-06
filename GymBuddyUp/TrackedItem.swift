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
    var bestRecordStr: String
    var isSkiped: Bool
    // TODO: read set from exercise
    init(_exercise: Exercise) {
        setsAmount = 1
        exercise = _exercise
        if _exercise.set.count > 0 {
            setsAmount = _exercise.set.count
            Log.info("setsAmount = \(setsAmount)")
        }
        finishedAmount = 0
        finishedSets = 0
        maxReps = 0
        maxWeight = 0
        isFinalized = false
        reps = [Int](count: setsAmount, repeatedValue: 0)
        weights = [Int](count: setsAmount, repeatedValue: 0)
        bestRecordStr = ""
        isSkiped = false
    }
    
    init (finishedAmount: Int, finishedSets: Int, exercise: Exercise, reps:[Int], weights:[Int]) {
        self.setsAmount = 1
        self.finishedAmount = finishedAmount
        self.finishedSets =  finishedSets
        self.exercise =  exercise
        self.reps = reps
        self.weights = weights
        self.maxReps = 0
        self.maxWeight = 0
        self.isFinalized = false
        self.bestRecordStr = ""
        self.isSkiped = false
    }
    
    init (finishedAmount: Int, finishedSets: Int, exercise: Exercise, reps:[Int], weights:[Int], maxReps: Int, maxWeight: Int, bestRecordStr: String, isSkiped: Bool) {
        self.setsAmount = 1
        self.finishedAmount = finishedAmount
        self.finishedSets =  finishedSets
        self.exercise =  exercise
        self.reps = reps
        self.weights = weights
        self.maxReps = maxReps
        self.maxWeight = maxWeight
        self.isFinalized = false
        self.bestRecordStr = bestRecordStr
        self.isSkiped = isSkiped
    }
    
    func saveOnNextExercise(onFinishedAmount: Int, onFinishedSets: Int) {
        finishedAmount = onFinishedAmount
        finishedSets = onFinishedSets
    }
    
    func saveOnNextSet(rep: Int, weight: Int) {
        reps[finishedSets] = rep
        weights[finishedSets] = weight
        finishedSets = min(setsAmount, finishedSets + 1)
        maxReps = max(rep, maxReps)
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