//
//  Discover.swift
//  GymBuddyUp
//
//  Created by Wei Wang on 8/21/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftDate
import Alamofire

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
private let userFriendsRef:FIRDatabaseReference! = ref.child("user_friend")
private let userWorkoutInviteRef:FIRDatabaseReference! = ref.child("user_workout_invite")

private let workoutInviteRef:FIRDatabaseReference! = ref.child("workout_invite")
private let publishedWorkoutLocationRef:FIRDatabaseReference! = ref.child("published_workout_location")


class Discover {
    
    class func discoverPublicWorkout(location: CLLocation, radiusInkilometers: Double, withinDays: Int, offset: Int?, completion: ([Invite], NSError?) -> Void) {
        // Query locations at input location with a radius of radius meters
        guard let currentUserId = User.currentUser?.userId else {return}
    
        var result = [Invite]()
        
        let geoQueryDispatchGroup = dispatch_group_create()
        
        // 今天不排序先。。。
        
        
        for i in (0 ..< withinDays)
        {
            dispatch_group_enter(geoQueryDispatchGroup)

            let date = (NSDate() + i.days).toString(DateFormat.Custom("yyyy-MM-dd"))
            print("DISCOVERING EVENTS for \(date!)")
            
            let geofire = GeoFire(firebaseRef: publishedWorkoutLocationRef.child(date!))
            let query = geofire.queryAtLocation(location, withRadius: radiusInkilometers)
            
            let fetchWorkoutDispatchGroup = dispatch_group_create()
            
            let observerHandle = query.observeEventType(.KeyEntered, withBlock: { (key: String!, foundLocation: CLLocation!) in
                dispatch_group_enter(fetchWorkoutDispatchGroup)
                workoutInviteRef.child(key).queryOrderedByChild("workout_time").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    var data = snapshot.value as! [String:AnyObject]
                    if data["available"] as? Bool != false && data["access"] as? Int > 1{
                        // add id to data dictionary
                        data["id"] = key
                        
                        let invite = Invite(JSON:data)!
                        print("invite.publishedTime: " + String(invite.publishedTime.timeIntervalSince1970))
                        if let isBlocked = User.currentUser?.blockedUserList[invite.inviterId]{
                        
                        }else{
                            let currentTime = NSDate()
                            if invite.inviterId != currentUserId && invite.isAvailable == true && currentTime < invite.publishedTime {
                                result.append(invite)
                            }
                        }
                    }
                    
                    dispatch_group_leave(fetchWorkoutDispatchGroup)
                })
            })
            
            query.observeReadyWithBlock({
                query.removeObserverWithFirebaseHandle(observerHandle)
                dispatch_group_notify(fetchWorkoutDispatchGroup, dispatch_get_main_queue()) {
                    
                    dispatch_group_leave(geoQueryDispatchGroup)
                }
            })
        }
        
        dispatch_group_notify(geoQueryDispatchGroup, dispatch_get_main_queue()) {
            result = result.reverse()
            completion(result, nil)
        }
    }
    
    class func discoverFriendsWorkout (withinDays: Int, completion: ([Invite], NSError?) -> Void) {
        
        // 1. get friends list
        // 2. for each friend, get active published workout. (workoutTime >= today && type > private (access > 0, 0 is private, 1 is friends, 2 is public) )
        // 3. for each workout id, filter by available = true
        // 4. for each workout 
        var invites = [Invite]()
        let getInvitesTaskGrp = dispatch_group_create()
       
        //let getInvitesTaskGrp2 = dispatch_group_create()
        userFriendsRef.child((User.currentUser?.userId)!).queryOrderedByChild("is_friend").queryEqualToValue(1).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            
            for friend in snapshot.children {
                dispatch_group_enter(getInvitesTaskGrp)
                // get this friend's active workout
                let friendUid = (friend as! FIRDataSnapshot).key
                print("friendUid :::::" + friendUid)
                let getInvitesTaskGrp1 = dispatch_group_create()
                let today = stringToDate(dateToString(NSDate()))
                //let today = stringToDate("2016-10-01")
                let interval = NSTimeInterval(60 * 60 * 24 * 3)
                let newDate = today!.dateByAddingTimeInterval(interval)
                userWorkoutInviteRef.child(friendUid).queryOrderedByChild("workout_time").queryStartingAtValue(dateToInt(today!))
                    .queryEndingAtValue(dateToInt(newDate)).observeSingleEventOfType(.Value, withBlock: { (userWorkoutInviteRef) in
                    
                        if let obj = userWorkoutInviteRef.value as? NSDictionary {
                    
                            for (key, value) in obj {
                                //dispatch_group_enter(getInvitesTaskGrp1)
                                let inviteid = (value as! NSDictionary)["invite"] as! String
                                print("invite :::::" + inviteid)
                                // now get this invite object
                                let access = (value as! NSDictionary)["access"] as! Int
                                if(access != 0){
                                    dispatch_group_enter(getInvitesTaskGrp1)
                                    
                                    workoutInviteRef.child(inviteid).observeSingleEventOfType(.Value, withBlock: { (inviteSnapshot) in
                                        if(inviteSnapshot.value is NSNull){
                                            print("invite is null")
                                        }else{
                                            var inviteData = inviteSnapshot.value as! [String: AnyObject]
                                            inviteData["id"] = key
                                            if let invite = Invite(JSON: inviteData){
                                                if invite.isAvailable != false && invite.accessLevel != 2 {
                                                    print("invite is not null " + invite.id)
                                                    invites.append(invite)
                                                }
                                            }
                                            
                                        }
                        
                                        dispatch_group_leave(getInvitesTaskGrp1)
                                    })
                                }
                            }
                        }
                        dispatch_group_notify(getInvitesTaskGrp1, dispatch_get_main_queue()) {
                            dispatch_group_leave(getInvitesTaskGrp)
                        }
                   
                    })
                }
            
                dispatch_group_notify(getInvitesTaskGrp, dispatch_get_main_queue()) {
                    completion(invites, nil)
                }
            })
        }
    
    

}