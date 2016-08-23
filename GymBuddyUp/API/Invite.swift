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

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
private let publishedWorkoutRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout")

class Invite {
    
    static var authenticationError : NSError = NSError(domain: FIRAuthErrorDomain, code: FIRAuthErrorCode.ErrorCodeUserTokenExpired.rawValue, userInfo: nil)
    
    class func sendFriendRequest(recipientId: String, completion: (NSError?) -> Void) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "send",
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
    
    class func rejectFriendRequest(requestId: String, completion: (NSError?) -> Void ) {
        
    }
    
    class func acceptFriendRequest(requestId: String, completion: (NSError?) -> Void ) {
        
    }
    
    class func sendWorkoutInviteToUser(recipientId: String, completion: (NSError?) -> Void ) {
        
    }
    
    class func publishWorkoutInviteToPublic(PlanId: String, scheduledWorkoutId: String, gymPlaceId: String, gymLocation: CLLocation, workoutTime: NSDate, completion: (NSError?) -> Void ) {
        let workoutRef = publishedWorkoutRef.childByAutoId()
        let workoutId = workoutRef.key
        let workoutPath = "/published_workout/\(workoutId)"
        var workoutData = [String:AnyObject]();
        
        workoutData["gym_place_id"] = gymPlaceId
        workoutData["workout_time"] = workoutTime.timeIntervalSince1970
        workoutData["plan"] = PlanId
        workoutData["scheduled_workout"] = scheduledWorkoutId
        workoutData["published_at"] = FIRServerValue.timestamp()
        workoutData["published_by"] = User.currentUser?.userId
        
        var userInviteData = [String:AnyObject]();
        let userInvitePath = "/user_workout_invite/\(User.currentUser!.userId)/\(workoutId)"
        userInviteData["access"] = "public"
        userInviteData["scheduled_workout"] = scheduledWorkoutId
        
        var inviteData = [String:AnyObject]();
        let invitePath = "/workout_invite/\(workoutId)"
        inviteData["inviter"] = User.currentUser?.userId
        inviteData["invitee"] = nil
        inviteData["accepted"] = false
        inviteData["confirmed"] = false
        inviteData["scheduled_workout"] = scheduledWorkoutId
        
        let fanoutObject = [workoutPath: workoutData, userInvitePath: userInviteData, invitePath: inviteData]
        
        ref.updateChildValues(fanoutObject) { (error, ref) in
            if (error != nil) {
                return completion(error)
            }
            
            let geofire = GeoFire(firebaseRef: workoutRef)
            geofire.setLocation(gymLocation, forKey: "gym_location") { (error) in
                completion(error)
            }
        }
    }
    
    class func publishWorkoutInviteToFriends(completion: (NSError?) -> Void ) {
        
    }
}

