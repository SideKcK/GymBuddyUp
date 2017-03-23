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
import FBSDKLoginKit

private let friendRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_friend")
private let userLocationRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_location")

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
            print("inside sendFriendRequest")
            Alamofire.request(.POST, "https://kr24xu120j.execute-api.us-east-1.amazonaws.com/prod/sidekck-notifications", parameters: parameters, encoding: .JSON)
                .responseJSON { response in
                    // Handle ERROR response from lambda server
                   
                    if !(Range(200..<300).contains((response.response?.statusCode)!)) {
                        print("reponse sendFriendRequest " + response.debugDescription)
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
    
    class func getFriendList(userId: String, completion: ([String]) -> Void) {
        var friends = [String]()
        friendRef.child(userId).queryOrderedByChild("is_friend").queryEqualToValue(1).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                for friend in snapshot.children {
                    friends.append(friend.ref.key)
                }
            
            completion(friends)
        })
    }
    
    class func isCurrentUserFriendWith(userToCheckWith:String, completion: FriendStatus -> Void) {
        guard let currentUserId = User.currentUser?.userId else {
            Log.info("No current user")
            return
        }
        friendRef.child(currentUserId).child(userToCheckWith).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            if let val = snapshot.value as? NSDictionary {
                let isFriend = val["is_friend"] as? Int
                if isFriend == 1 {
                    completion(FriendStatus.isFriend)
                    Log.info("is friend")

                }
                else if isFriend == 0 {
                    completion(FriendStatus.requestPending)
                }
            }
            
            else {
                completion(FriendStatus.notFriend)
                Log.info("nof friend")
            }
            
        })
    }
    
    class func discoverNearbyUsers(location: CLLocation, withinMiles: Int = 20)
    {
        
    }
    
    class func discoverNewBuddies(location: CLLocation, radiusInkilometers: Double, completion: ([User], NSError?) -> Void) {
        // Query locations at input location with a radius of radius meters
        
        //let geoQueryDispatchGroup = dispatch_group_create()
        var userList = [User]()
        
        print("inside discoverNewBuddies " + String(location.coordinate.longitude))
        //dispatch_group_enter(geoQueryDispatchGroup)
        
        
        let geofire = GeoFire(firebaseRef: userLocationRef)
        let query = geofire.queryAtLocation(location, withRadius: radiusInkilometers)
        
        let fetchWorkoutDispatchGroup = dispatch_group_create()
        print("before query")
        
        let blockedUserList = User.currentUser!.blockedUserList

            let observerHandle = query.observeEventType(.KeyEntered, withBlock: { (key: String!, foundLocation: CLLocation!) in

                dispatch_group_enter(fetchWorkoutDispatchGroup)
                if(key != User.currentUser?.userId){
                    if let isBlocked = blockedUserList[key]{
                        dispatch_group_leave(fetchWorkoutDispatchGroup)
                    }else{
                        isCurrentUserFriendWith(key , completion: { (friendStatus) in
                            if friendStatus != FriendStatus.isFriend {
                                User.getUserById(key, successHandler: { (user: User) in
                                    user.userlocation = foundLocation
                                    user.distance = User.currentUser?.userlocation!.distanceFromLocation(user.userlocation!)
                                    userList.append(user)
                                    dispatch_group_leave(fetchWorkoutDispatchGroup)
                                })
                            }else{
                                dispatch_group_leave(fetchWorkoutDispatchGroup)
                            }
                        })
                    }
                }else{
                    dispatch_group_leave(fetchWorkoutDispatchGroup)
                }
            })
            
            query.observeReadyWithBlock({
                print("observeReadyWithBlock")
                
                dispatch_group_notify(fetchWorkoutDispatchGroup, dispatch_get_main_queue()) {
                    
                    print("dispatch_group_leave(fetchWorkoutDispatchGroup)")
                    query.removeObserverWithFirebaseHandle(observerHandle)
                    userList.sortInPlace({ $0.distance < $1.distance })
                    completion(userList, nil)
                }
            })
    }
    
    class func discoverFBFriends(completion: ([User], NSError?) -> Void){
        let params = ["fields": "id, first_name, last_name, middle_name, name, email, picture"]
        var userList = [User]()
        if let tokenString = User.currentUser?.facebookAccesstoken{
            
            let blockedUserList = User.currentUser!.blockedUserList
            let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: params, tokenString: tokenString, version: nil, HTTPMethod: "GET")
            request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                print("inside discoverFBFriends 11 " + tokenString)
           
                if error != nil {
                    print("inside discoverFBFriends error")
                    let errorMessage = error.localizedDescription /* Handle error */
                    print(error.userInfo[FBSDKErrorDeveloperMessageKey] )
                    print(errorMessage)
                } else if result.isKindOfClass(NSDictionary){ /* handle response */
                    for (key, value) in result as! NSDictionary {
                        let _key  = key as! String
                        switch(_key){
                        case "data":
                            let stringMirror = Mirror(reflecting: value)
                            print(stringMirror.subjectType)
                            let data : NSArray = (value as? NSArray)!
                            let fetchWorkoutDispatchGroup = dispatch_group_create()
                            
                            for friend in data{
                                print("inside discoverFBFriends no error NSArray")
                                let _friend = friend as! NSDictionary
                                dispatch_group_enter(fetchWorkoutDispatchGroup)
                                User.getUserByFacebookId(_friend["id"] as! String,successHandler: { (user: User) in
                                    print(user.screenName)
                                    if let isBlocked = blockedUserList[user.userId!]{
                                    }else{
                                        userList.append(user)
                                    }
                                    print("before release fetchWorkoutDispatchGroup")
                                    dispatch_group_leave(fetchWorkoutDispatchGroup)
                                    }, failureHandler: {(error) in
                                    dispatch_group_leave(fetchWorkoutDispatchGroup)
                                
                                } )
                                print("Facebook id :" + String(friend["id"]))
                            }
                             dispatch_group_notify(fetchWorkoutDispatchGroup, dispatch_get_main_queue()) {
                                print("completion(userList, nil) :")
                                completion(userList, nil)
                             }
                        break
                        case "summary":
                            print("summary" + String(value["total_count"] as! Int) )
                        break
                        default:
                            Log.info("no key matches")
                        }
                    
                    }
                    print(" dispatch_group_leave(fetchWorkoutDispatchGroup) :")
                }
            
            }
        }else{
             completion(userList, nil)
        }
    }

}

