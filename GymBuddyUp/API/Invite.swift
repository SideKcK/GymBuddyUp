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
import ObjectMapper

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
private let userInviteRef:FIRDatabaseReference! = ref.child("user_workout_invite")
private let workoutInviteRef:FIRDatabaseReference! = ref.child("workout_invite")
private let publishedWorkoutLocationRef:FIRDatabaseReference! = ref.child("published_workout_location")


class Invite : Mappable {
    var id: String!
    var canceledByInviter: Bool!
    var canceledByInvitee: Bool!
    var isAvailable: Bool!

    var gym: Gym?
    var inviterId: String!
    var inviteeId: String?
    var planId: String!
    var workoutTime: NSDate!
    var sentTo: String!
    var accessLevel: Int!
    var publishedTime: NSDate!
    
    required init?(_ map: Map) {
        
    }
    
    init () {
        //self.canceledByInviter = false
        self.id = "-1"
    
    }
    // Mappable
    func mapping(map: Map) {
        id <- map["id"] // there is not field named id
        canceledByInviter <- map["canceled_by_inviter"]
        canceledByInvitee <- map["canceled_by_invitee"]
        gym <- map["gym"]
        inviterId <- map["inviter"]
        inviteeId <- map["invitee"] // there is not field named id
        planId <- map["plan"]
        workoutTime <- (map["workout_time"], DateTransform())
        sentTo <- map["sent_to"]
        accessLevel <- map["access"]
        isAvailable <- map["available"]
        publishedTime <- (map["published_at"], DateTransform())
    }
    
    
    static var authenticationError : NSError = NSError(domain: FIRAuthErrorDomain, code: FIRAuthErrorCode.ErrorCodeUserTokenExpired.rawValue, userInfo: nil)
    
    class func getWorkoutInviteByScheduledWorkoutIdAndDate(scheduledWorkoutId: String, date: NSDate, completion: (NSError?, Invite?) -> Void )
    {
        let userInviteId = scheduledWorkoutId + ":" + dateToString(date)
        if let userId = User.currentUser?.userId! {
            userInviteRef.child(userId).child(userInviteId).child("invite").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if snapshot.value == nil {
                    return completion(nil, nil)
                }
                
                if let inviteId:String = snapshot.value as? String {
                    ref.child("workout_invite").child(inviteId).observeSingleEventOfType(.Value, withBlock: {
                        (inviteSnapshot)  in
                        guard let data = inviteSnapshot.value as? [String: AnyObject] else
                        {
                            return completion (nil, nil)
                        }
                        
                        var mapData = data
                        mapData["id"] = inviteId
                        completion(nil, Invite(JSON:mapData))
                    })
                }
            })
        }
        else {
            completion(authenticationError, nil)
        }
    }
    
    internal class func sendWorkoutInviteToUser(recipientId: String, inviteId: String, completion: (NSError?) -> Void ) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "workout_invite_send",
                "recipientId": recipientId,
                "workoutId": inviteId
            ]
            
            Alamofire.request(.POST, "https://kr24xu120j.execute-api.us-east-1.amazonaws.com/prod/sidekck-notifications", parameters: parameters, encoding: .JSON)
                .responseJSON { response in
                    // Handle ERROR response from lambda server
                    if !(Range(200..<300).contains((response.response?.statusCode)!)) {
                        let error = NSError(domain: "APIErrorDomain", code: (response.response?.statusCode)!, userInfo: ["result":response.result.value!])
                        completion(error)
                    }
                    else {
                        Log.info("direct invitation sent successfully!")
                        completion(nil)
                    }
            }
        }

    }
    
    class func acceptWorkoutInvite(inviteId: String, workoutTime: NSDate, completion: (NSError?) -> Void ) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "workout_invite_accept",
                "workoutId": inviteId,
                "workout_time": dateToString(workoutTime) 
            ]
            
            Alamofire.request(.POST, "https://y1avc048jl.execute-api.us-east-1.amazonaws.com/dev/notification", parameters: parameters, encoding: .JSON)
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
            
            Alamofire.request(.POST, "https://kr24xu120j.execute-api.us-east-1.amazonaws.com/prod/sidekck-notifications", parameters: parameters, encoding: .JSON)
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
            
            Alamofire.request(.POST, "https://kr24xu120j.execute-api.us-east-1.amazonaws.com/prod/sidekck-notifications", parameters: parameters, encoding: .JSON)
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
    
    internal class func publishWorkoutInvite(sendTo: String, planId: String, scheduledWorkoutId: String, gym:Gym, workoutTime: NSDate, completion: (NSError?) -> Void )
    {
        var accessLevel = 0
        
        switch sendTo {
        case "public":
            accessLevel = 2
            
        case "friends":
            accessLevel = 1
        
        default:
            accessLevel = 0
        }
        
        // Create a unique ID for this invite.
        let inviteRef = workoutInviteRef.childByAutoId()
        let inviteId = inviteRef.key
        
        var inviteData = [String:AnyObject]();
        let invitePath = "/workout_invite/\(inviteId)"
        inviteData["inviter"] = User.currentUser?.userId
        inviteData["invitee"] = nil
        inviteData["sent_to"] = sendTo
        inviteData["access"] = accessLevel
        inviteData["canceled_by_inviter"] = false
        inviteData["canceled_by_invitee"] = false
        inviteData["plan"] = planId
        inviteData["gym"] = gym.toDictionary()
        inviteData["workout_time"] = workoutTime.timeIntervalSince1970
        inviteData["workout_date"] = dateToString(workoutTime)
        inviteData["published_at"] = FIRServerValue.timestamp()
        inviteData["available"] = true
        
        // Create a user_workout_invite node for this user.
        var userInviteData = [String:AnyObject]();
        let userInvitePath = "/user_workout_invite/\(User.currentUser!.userId)/\(scheduledWorkoutId):\(dateToString(workoutTime))"
        userInviteData["access"] = accessLevel
        userInviteData["sent_to"] = sendTo
        userInviteData["scheduled_workout"] = scheduledWorkoutId
        userInviteData["workout_time"] = workoutTime.timeIntervalSince1970
        userInviteData["invite"] = inviteId
        
        // Fanout data to update
        let fanoutObject = [userInvitePath: userInviteData, invitePath: inviteData]
        
        // Update fantout object
        ref.updateChildValues(fanoutObject) { (error, ref) in
            if (error != nil) {
                return completion(error)
            }
            
            switch sendTo {
                
            case "public" : // if send to public, log additional geolocation data.
                // figure out where to put location data
                let date = workoutTime.toString(DateFormat.Custom("yyyy-MM-dd"))
                let geofire = GeoFire(firebaseRef: publishedWorkoutLocationRef.child(date!))
                geofire.setLocation(gym.location, forKey: inviteId) { (error) in
                    if error != nil {
                        print(error)
                    }
                    completion(error)
                    }
                
            case "friends" :
                completion(error)
                
            default: // send to public or a specific user
                sendWorkoutInviteToUser(sendTo, inviteId: inviteId, completion: { (error) in
                    print(error)
                    completion(error)
                })
            }
        }
    }
    
    class func getWorkoutInviteById(workoutId: String, completion: (NSError?, Invite?) -> Void) {
        workoutInviteRef.child(workoutId).queryOrderedByChild("workout_time").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let data = snapshot.value as! [String:AnyObject]
            completion(nil, Invite(JSON: data))
        })
    }
    
    class func publishWorkoutInviteToPublic(planId: String, scheduledWorkoutId: String, gym:Gym, workoutTime: NSDate, completion: (NSError?) -> Void ) {
        publishWorkoutInvite("public", planId: planId, scheduledWorkoutId: scheduledWorkoutId, gym: gym, workoutTime: workoutTime, completion: completion)
    }
    
    class func publishWorkoutInviteToFriends(planId: String, scheduledWorkoutId: String, gym:Gym, workoutTime: NSDate, completion: (NSError?) -> Void ) {
        publishWorkoutInvite("friends", planId: planId, scheduledWorkoutId: scheduledWorkoutId, gym: gym, workoutTime: workoutTime, completion: completion)
    }
    
    class func publishWorkoutInviteToUser(sendTo: String, PlanId: String, scheduledWorkoutId: String, gym:Gym, workoutTime: NSDate, completion: (NSError?) -> Void )
    {
        publishWorkoutInvite(sendTo, planId: PlanId, scheduledWorkoutId: scheduledWorkoutId, gym: gym, workoutTime: workoutTime, completion: completion)
    }
    
    class func testfunction()
    {
//        User.currentUser?.getTokenForcingRefresh({ (token, error) in
//            print(token)
//        })
//        
//        Invite.publishWorkoutInviteToPublic("KOZM75uwOUmdflVo2wH", scheduledWorkoutId: "-KQsDEMmVnYNDo_j9yMy", gym: Gym(), workoutTime: NSDate()) { (err) in
//            print(err)
//        }
        
//        getWorkoutInviteByScheduledWorkoutIdAndDate("-KQsDEMmVnYNDo_j9yMy", date: stringToDate("2016-09-13")!) { (error, invite) in
//            
//            print (error, invite)
//        }
    }
}

