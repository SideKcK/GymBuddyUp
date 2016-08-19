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

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout")
private let storageRef = FIRStorage.storage().reference()

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
    
    class func sendWorkoutInvite(recipientId: String, completion: (NSError?) -> Void ) {
        
    }
    
    class func sendWorkoutInviteToPublic(completion: (NSError?) -> Void ) {
        
    }
    
    class func sendWorkoutInviteToFriends(completion: (NSError?) -> Void ) {
        
    }
}

