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

class BestRecord{
    var exerciseId: Int!
    var createDate:String?
    var bestRecord:Int!
    
    init (exerciseId: Int, createDate:String , dict: NSDictionary) {
        self.exerciseId = exerciseId
        self.createDate = createDate
        self.bestRecord = dict.valueForKey("best_record") as? Int
    }
    
    
}




