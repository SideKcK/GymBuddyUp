//
//  InboxMessage.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/27/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Firebase
import FirebaseDatabase
import Alamofire
import SwiftDate

private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
private let publishedWorkoutRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout")
private let publishedWorkoutLocationRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("published_workout_location")
private let inboxMessageRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("inbox_message")

enum InboxMessageType {
    case FriendRequest
    case Invitation
    case Undefined
}

class InboxMessage {
    var type: InboxMessageType
    var associatedId: String?
    var content: String
    var senderId: String
    var receiverId: String
    var senderName: String?
    var senderAvatarUrl: NSURL?
    var senderAvatarImage: UIImage?

    // create a new InboxMessage
    init(_type: InboxMessageType, _content: String, _senderId: String, _receiverId: String, _associatedId: String?, _senderName: String?, _senderAvatarUrl: NSURL?) {
        type = _type
        content = _content
        senderId = _senderId
        receiverId = _receiverId
        
        if type == .Invitation {
            associatedId = _associatedId
        }
        
        senderName = _senderName
        senderAvatarUrl = _senderAvatarUrl
    }
    
    /* TODO: create inbox message from FIRDataSnapshot
    init(snapshot: FIRDataSnapshot) {
        
    
    
    }
    */
    
    class func test() {
        
        // qALhTBIB1GX37OY0nLcZ369RlY52
        inboxMessageRef.child("qALhTBIB1GX37OY0nLcZ369RlY52").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            print(snapshot)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        
//        guard let uid = User.currentUser?.userId else {return}
//        let key = inboxMessageRef.childByAutoId().key
//
//        let post = ["senderId": "aasdasd",
//                    "receiverId": "asdasd",
//                    "senderName": "title",
//                    "body": "body",
//                    "timestamp": FIRServerValue.timestamp()]
//        inboxMessageRef.child("\(uid)/\(key)").setValue(post)
    }
    
    func saveToBackend() {
        switch type {
        case .FriendRequest:
            // friend request save procedure
            break
        case .Invitation:
            // invitation save procedure
            break
        default:
            Log.info("undefied inbox message type")
        }
    }
}