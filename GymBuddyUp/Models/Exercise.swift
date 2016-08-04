//
//  Exercise.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

let testURL = NSURL(string: "http://www.building-muscle101.com/images/bench_press.jpg")
class Exercise {
    var name: String!
    var thumbURL: NSURL!
    var gifURL: NSURL!
    var description: String!
    var setEnabled: Bool!
    
    var duration: NSDate?
    var numSets: Int?
    
    init () {
        name = "test exercise"
        thumbURL = testURL
        gifURL = testURL
        description = "this is a test exercise: The bench press is an upper body strength training exercise that consists of pressing a weight upwards from a supine position. The exercise works the pectoralis major as well as supporting chest, arm, and shoulder muscles such as the anterior deltoids, serratus anterior, coracobrachialis, scapulae fixers, trapezii, and the triceps."
        setEnabled = true
        numSets = 3
    }
    
    
    init (dict: NSDictionary) {
        //parse nsdict to exer
    }
    
    class func exersWithArray(array: [NSDictionary]) -> [Exercise] {
        var exers = [Exercise]()
        
        for dictionary in array {
            exers.append(Exercise(dict: dictionary))
        }
        return exers
    }
    

}
