//
//  MidCat.swift
//  GymBuddyUp
//
//  Created by you wu on 8/4/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MidCat {
    var id: Int?
    var name: String?
    
    init () {
        self.name = "test cat"
        self.id = -1
    }
    
    init (dict: NSDictionary) {
        //parse nsdict
        if let name = dict["name"] as? String,
            id = dict["id"] as? Int {
            self.name = name
            self.id = id
        }
    }
    
    class func catsWithArray(array: [NSDictionary]?) -> [MidCat]? {
        var res = [MidCat]()
        
        guard let arr = array else {
            return res
        }
        for dictionary in arr {
            res.append(MidCat(dict: dictionary))
        }
        return res
    }

}