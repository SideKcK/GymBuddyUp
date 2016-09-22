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

private let friendRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_friend")

class Friend {
    
    enum FriendStatus: Int {
        case isFriend = 1
        case requestPending = 0
        case notFriend = -1
    }
    
    static var authenticationError : NSError = NSError(domain: FIRAuthErrorDomain, code: FIRAuthErrorCode.ErrorCodeUserTokenExpired.rawValue, userInfo: nil)
    
    
    class func sendFriendRequest(recipientId: String, completion: (NSError?) -> Void) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "friend_request_send",
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
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "friend_request_reject",
                "requestId": requestId
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
    
    class func acceptFriendRequest(requestId: String, completion: (NSError?) -> Void ) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "friend_request_accept",
                "requestId": requestId
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
    
    class func getFriendList(userId: String, completion: ([String]) -> Void)
    {
        var friends = [String]()
        friendRef.child(userId).queryOrderedByChild("is_friend").queryEqualToValue(1).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                for friend in snapshot.children {
                    friends.append(friend.ref.key)
                }
            
            completion(friends)
        })
    }
    
    class func isCurrentUserFriendWith(userToCheckWith:String, completion: FriendStatus -> Void) {
        friendRef.child((User.currentUser?.userId)!).child(userToCheckWith).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            if let val = snapshot.value as? NSDictionary {
                let isFriend = val["is_friend"] as? Int
                if isFriend == 1 {
                    completion(FriendStatus.isFriend)
                }
                else if isFriend == 0 {
                    completion(FriendStatus.requestPending)
                }
            }
            
            else {
                completion(FriendStatus.notFriend)
            }
            
        })
    }
    
    class func discoverNearbyUsers(location: CLLocation, withinMiles: Int = 20)
    {
        
    }
}

