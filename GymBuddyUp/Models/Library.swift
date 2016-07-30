//
//  Library.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class Library {
    
    class func getCategoryNames() -> [String] {
        
        return ["Shoulder", "Arms", "Chest", "Abs", "Back"]
    }
    
    class func getPlans(catID: Int) -> [Plan]{
        return [Plan(), Plan()]
    }
}


