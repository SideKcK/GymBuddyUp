//
//  invite.swift
//  GymBuddyUp
//
//  Created by Wei Wang on 8/16/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import Alamofire
import SwiftDate

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
private let publishedWorkoutRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout")
private let publishedWorkoutLocationRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout_location")


class Invite {
    
    enum InviteStatus:Int {
        case pending = 1
        case accepted = 2
        case canceled = 0
    }
    
    var accepted: Bool
    var confirmed: Bool
    var canceled: Bool
    var gym: Gym
    var inviterId: String
    var inviteeId: String?
    var planId: String
    var workoutTime: NSDate
    
    var status: InviteStatus

    
    
    static var authenticationError : NSError = NSError(domain: FIRAuthErrorDomain, code: FIRAuthErrorCode.ErrorCodeUserTokenExpired.rawValue, userInfo: nil)
    
    class func getWorkoutInviteByScheduledWorkoutIdAndDate(scheduledWorkoutId: String, date: NSDate, completion: (NSError?) -> Void ) {
        
    }
    
    class func sendWorkoutInviteToUser(recipientId: String, completion: (NSError?) -> Void ) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "workout_invite_send",
                "recipientId": recipientId
            ]
            
            Alamofire.request(.POST, "https://q08av7imrj.execute-api.us-east-1.amazonaws.com/dev/friend-request", parameters: parameters, encoding: .JSON)
                .responseJSON { response in
                    // Handle ERROR response from lambda server
                    if !(Range(200..<300).contains((response.response?.statusCode)!)) {
                        let error = NSError(domain: "APIErrorDomain", code: (response.response?.statusCode)!, userInfo: ["result":response.result.value!])
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
            }
        }

    }
    
    class func acceptWorkoutInvite(inviteId: String, completion: (NSError?) -> Void ) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "workout_invite_accept",
                "workoutId": inviteId
            ]
            
            Alamofire.request(.POST, "https://q08av7imrj.execute-api.us-east-1.amazonaws.com/dev/friend-request", parameters: parameters, encoding: .JSON)
                .responseJSON { response in
                    // Handle ERROR response from lambda server
                    if !(Range(200..<300).contains((response.response?.statusCode)!)) {
                        let error = NSError(domain: "APIErrorDomain", code: (response.response?.statusCode)!, userInfo: ["result":response.result.value!])
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
            }
        }
    }
    
    class func cancelWorkoutInvite(inviteId: String, completion: (NSError?) -> Void) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "workout_invite_cancel",
                "workoutId": inviteId
            ]
            
            Alamofire.request(.POST, "https://q08av7imrj.execute-api.us-east-1.amazonaws.com/dev/friend-request", parameters: parameters, encoding: .JSON)
                .responseJSON { response in
                    // Handle ERROR response from lambda server
                    if !(Range(200..<300).contains((response.response?.statusCode)!)) {
                        let error = NSError(domain: "APIErrorDomain", code: (response.response?.statusCode)!, userInfo: ["result":response.result.value!])
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
            }
        }
    }
    
    class func rejectWorkoutInvite(inviteId: String, completion: (NSError?) -> Void) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "workout_invite_reject",
                "workoutId": inviteId
            ]
            
            Alamofire.request(.POST, "https://q08av7imrj.execute-api.us-east-1.amazonaws.com/dev/friend-request", parameters: parameters, encoding: .JSON)
                .responseJSON { response in
                    // Handle ERROR response from lambda server
                    if !(Range(200..<300).contains((response.response?.statusCode)!)) {
                        let error = NSError(domain: "APIErrorDomain", code: (response.response?.statusCode)!, userInfo: ["result":response.result.value!])
                        completion(error)
                    }
                    else {
                        completion(nil)
                    }
            }
        }
    }
    
    
    class func publishWorkoutInviteToPublic(PlanId: String, scheduledWorkoutId: String, gym:Gym, workoutTime: NSDate, completion: (NSError?) -> Void ) {
        
        let workoutRef = publishedWorkoutRef.childByAutoId()
        let workoutId = workoutRef.key
        let workoutPath = "/published_workout/\(workoutId)"
        var workoutData = [String:AnyObject]();
        
        workoutData["workout_time"] = workoutTime.timeIntervalSince1970
        workoutData["plan"] = PlanId
        workoutData["scheduled_workout"] = scheduledWorkoutId
        workoutData["published_at"] = FIRServerValue.timestamp()
        workoutData["published_by"] = User.currentUser?.userId
        workoutData["available"] = true
        workoutData["gym"] = gym.toDictionary()
        
        var userInviteData = [String:AnyObject]();
        let userInvitePath = "/user_workout_invite/\(User.currentUser!.userId)/\(scheduledWorkoutId):\(dateToString(workoutTime))"
        userInviteData["access"] = "public"
        userInviteData["scheduled_workout"] = scheduledWorkoutId
        userInviteData["invite"] = workoutId
        
        var inviteData = [String:AnyObject]();
        let invitePath = "/workout_invite/\(workoutId)"
        inviteData["inviter"] = User.currentUser?.userId
        inviteData["invitee"] = nil
        inviteData["canceled_by_inviter"] = false
        inviteData["canceled_by_invitee"] = false
        inviteData["plan"] = PlanId
        inviteData["gym"] = gym.toDictionary()
        inviteData["workout_time"] = workoutTime.timeIntervalSince1970

        
        let fanoutObject = [workoutPath: workoutData, userInvitePath: userInviteData, invitePath: inviteData]
        
        ref.updateChildValues(fanoutObject) { (error, ref) in
            if (error != nil) {
                return completion(error)
            }
            
            // figure out where to put location data
            let date = workoutTime.toString(DateFormat.Custom("yyyy-MM-dd"))
            let geofire = GeoFire(firebaseRef: publishedWorkoutLocationRef.child(date!))
            geofire.setLocation(gym.location, forKey: workoutId) { (error) in
                if error != nil {
                    print(error)
                }
                completion(error)
            }
        }
    }
    
    class func publishWorkoutInviteToFriends(completion: (NSError?) -> Void ) {
        
    }
    
    class func testfunction()
    {
        User.currentUser?.getTokenForcingRefresh({ (token, error) in
            print(token)
        })
        
        Invite.publishWorkoutInviteToPublic("KOZM75uwOUmdflVo2wH", scheduledWorkoutId: "-KQsDEMmVnYNDo_j9yMy", gym: Gym(), workoutTime: NSDate()) { (err) in
            print(err)
        }
    }
}

