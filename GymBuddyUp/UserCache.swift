//
//  UserCache.swift
//  GymBuddyUp
//
//  Created by YiHuang on 10/10/2016.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation

class UserCache {
    
    //MARK: Shared Instance
    
    static let sharedInstance : UserCache = {
        let instance = UserCache()
        return instance
    }()
    
    //MARK: Local Variable
    var cache = [String : User]()
    
    //MARK: Init
    
    init() {

    }
}