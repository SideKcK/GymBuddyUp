//
//  InvitationCache.swift
//  GymBuddyUp
//
//  Created by YiHuang on 27/10/2016.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation

class InvitationCache {
    
    //MARK: Shared Instance
    
    static let sharedInstance : InvitationCache = {
        let instance = InvitationCache()
        return instance
    }()
    
    //MARK: Local Variable
    var cache = [String : InvitationCache]()
    
    //MARK: Init
    
    init() {
        
    }
}