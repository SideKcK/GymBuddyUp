//
//  User.swift
//  GymBuddyUp
//
//  Created by you wu on 5/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class User {

    enum Gender {
        case Male
        case Female
        case Unspecified
    }
    
    enum Goal {
        case Fit
        case Weight
        case Muscle
        case Fun
    }
    
    var id: String!
    
    var userName: String?//to WW: replace some of these variables with FirebaseUser when neccessary. for example i think email might be accessible from the FireBaseUser instance
    var email: String?
    var screenName: String?
    var isActivated: Bool?
    var isMember: Bool?
    var memberExpireDate: String?
    var memberAutoUpdate: Bool?
    var gender: Gender?
    //to WW: possible variable for profile image file?
    
    var workoutNum: Int?
    var starNum: Int?
    var likeNum: Int?
    var dislikeNum: Int?
    var buddyNum: Int?
    
    var goal: Goal?
    var gym: String? //to WW: or change it to CLLocationCoordinates if thats better for backend
    var description: String?
    
    var distance: Double?
    var sameInterestNum: Int?
    var interestList: NSDictionary?
    
    static var currentUser: User?
    
    init () {
        self.userName = "test"
        self.screenName = "TEST"
        self.workoutNum = 11
        self.starNum = 21
        self.buddyNum = 10
        self.likeNum = 19
        self.goal = .Fit
        self.gym = "Life Fitness"
        self.description = "Test description"
    }
    //to WW: change it to init func from FireBaseUser to user
    //so it should be init (response: FireBaseUserClass/FireBaseUserLoginResponse)
    init (response: NSDictionary) {
        self.id = response["id"] as! String
        self.userName = response["userName"] as? String
    }
    
    class func toString(goal: Goal) -> String{
        var goalString = ""
        switch goal {
        case User.Goal.Fit:
            goalString = "Keep Fit"
            break
        case User.Goal.Weight:
            goalString = "Lose Weight"
            break
        case User.Goal.Muscle:
            goalString = "Build Muscle"
            break
        case User.Goal.Fun:
            goalString = "Have Fun"
            break
        }
        return goalString
    }
}
