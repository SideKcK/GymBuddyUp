//
//  User.swift
//  GymBuddyUp
//
//  Created by you wu on 5/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class User {

    var id: String!
    var token: String!
    
    var userName: String?
    var email: String?
    var nickName: String?
    var isActivated: Bool?
    var isMember: Bool?
    var memberExpireDate: String?
    var memberAutoUpdate: Bool?
    var likeNum: Int?
    var dislikeNum: Int?
    var distance: Double?
    var sameInterestNum: Int?
    var interestList: NSDictionary?
    
    static var currentUser: User?
    
    init (userID: String!, token: String!) {
        self.token = token
        self.id = userID
    }
    
    init (response: NSDictionary) {
        self.id = response["id"] as! String
        self.userName = response["userName"] as? String
    }
}
