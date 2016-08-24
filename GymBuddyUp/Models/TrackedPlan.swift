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

class TrackedPlan {
    weak var plan: Plan?
    var trackingId: String?
    var user: User?
    var trackingItems = [TrackedItem]()
    
    init(plan: Plan) {
        self.plan = plan
        if let exercises = plan.exercises {
            Log.info("if let exercises = plan.exercises {")
            for exercise in exercises {
                let trackingItem =  TrackedItem(_exercise: exercise)
                trackingItems.append(trackingItem)
            }
        }
    }
    
    init(planId: String) {
    
    }
    
    init(planDict: NSDictionary) {
        
    }
    
    func saveToBackend() {
    
    }

}

