//
//  Report.swift
//  GymBuddyUp
//
//  Created by lingchao kong on 16/11/9.
//  Copyright © 2016年 You Wu. All rights reserved.
//


import Foundation
import CoreLocation

import Firebase
import FirebaseDatabase
import FirebaseStorage

import Alamofire

private let ref: FIRDatabaseReference! = FIRDatabase.database().reference()
private let userBlockRef:FIRDatabaseReference! = ref.child("user_block")
private let userInviteBlockRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_invite_block")
private let userFreindRef:FIRDatabaseReference! = ref.child("user_friend")
private let userReportRef:FIRDatabaseReference! = ref.child("user_report")

func dateToStringWithHour(date: NSDate)->String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    let dateString = dateFormatter.stringFromDate(date)
    return dateString
}
class Report{
    
    class func sendReport(actionType: String!, reportItemId: String!, completion: (NSError?) -> Void) {
        
        let parameters = [
            "from": User.currentUser?.userId!,
            "reportItemId": reportItemId,
            "actionType": actionType
        ]
        
        Alamofire.request(.POST, "http://www.sidekckapp.com/php/report.php", parameters: parameters, encoding: .JSON)
            .responseJSON { response in
               completion(nil)
        }
       
        
    }
    class func addReport(actionType: String!, reportItemId: String!, completion: (NSError?) -> Void) {
        let parameters = [
            "from": User.currentUser?.userId!,
            "reportItemId": reportItemId,
            "actionType": actionType
        ]
        let today = NSDate()
        let reportId = dateToStringWithHour(today) + ":" + (User.currentUser?.userId)!
        let attrRef = userReportRef.child("\(reportId)")
        attrRef.setValue(parameters)
        completion(nil)
    }

    
    class func blockUser(targetUserId: String, completion: (NSError?) -> Void) {
        print("inside blockUser" + targetUserId)
        var ref = userBlockRef.child("\(User.currentUser!.userId)")
        var attrRef = ref.child("\(targetUserId)")
        attrRef.setValue(true)
        ref = userBlockRef.child("\(targetUserId)")
        attrRef = ref.child("\(User.currentUser!.userId)")
        attrRef.setValue(true)
        userFreindRef.child("\(User.currentUser!.userId)").child("\(targetUserId)").removeValue()
        userFreindRef.child("\(targetUserId)").child("\(User.currentUser!.userId)").removeValue()
        completion(nil)
    }
    
    class func blockUserInvite(targetUserInviteId: String, completion: (NSError?) -> Void) {
        let ref = userInviteBlockRef.child("\(User.currentUser!.userId)")
        let attrRef = ref.child("\(targetUserInviteId)")
        attrRef.setValue(true)
        completion(nil)
    }
    
    class func getBlockUsers(completion: (content:NSDictionary?, error:NSError?) -> Void) {
        let ref = userBlockRef.child("\(User.currentUser!.userId)")
        ref.observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            print("inside getBlockUsers")
            let values = snapshot.value as? NSDictionary
            
            completion(content: values, error: nil)
        }) {
            (error) in
            completion(content: nil, error: error)
        }
    }
    
    class func getBlockUserInvites(completion: (content:[NSDictionary]?, error:NSError?) -> Void) {
        let ref = userInviteBlockRef.child("\(User.currentUser!.userId)")
        ref.observeSingleEventOfType(.Value, withBlock: {
            (snapshot) in
            let value = snapshot.valueInExportFormat() as? NSDictionary
            let entries = value?.allValues as? [NSDictionary]
            completion(content: entries, error: nil)
        }) {
            (error) in
            completion(content: nil, error: error)
        }
    }
    
}


