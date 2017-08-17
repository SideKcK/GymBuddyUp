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
private let pushNotificatoinRef: FIRDatabaseReference! = FIRDatabase.database().reference().child("user_notification")





class InboxMessage {
    var messageId: String
    var type: InboxMessageType
    var isProcessed: Bool
    var isIgnore: Bool
    var associatedId: String?
    var senderId: String
    var content: String?
    var receiverId: String?
    var senderName: String?
    var senderAvatarUrl: NSURL?
    var senderAvatarImage: UIImage?
    var timeStamp: NSDate?
    
    enum MessageAction {
        case Accept
        case Reject
        case Cancel
    }
    
    enum InboxMessageType {
        case FriendRequestReceived
        case FriendRequestRejected
        case FriendRequestAccepted
        case WorkoutInviteReceived
        case WorkoutInviteRejected
        case WorkoutInviteAccepted
        case WorkoutInviteCanceled
    }
    
    static let inboxMessageMap: [String: InboxMessageType] = [
        "friend_request_received": .FriendRequestReceived,
        "friend_request_rejected": .FriendRequestRejected,
        "friend_request_accepted": .FriendRequestAccepted,
        "workout_invite_received": .WorkoutInviteReceived,
        "workout_invite_rejected": .WorkoutInviteRejected,
        "workout_invite_accepted": .WorkoutInviteAccepted,
        "workout_invite_canceled": .WorkoutInviteCanceled
    ]

    init(_messageId: String, _type: String, _senderId: String, _associatedId: String?, _senderName: String, _timeStamp: Double) {
        messageId = _messageId
        type = InboxMessage.inboxMessageMap[_type]!
        associatedId = _associatedId
        senderId = _senderId
        senderName = _senderName
        print("senderName: " + senderName!)
        isIgnore = false
        isProcessed = false
        timeStamp = NSDate(timeIntervalSince1970: _timeStamp / 1000)
        setType(_type)
    }
    
    func process(action: MessageAction) {
        guard let userId = User.currentUser?.userId else {return}
        if type == .FriendRequestReceived {
            switch action {
            case .Accept:
                Friend.acceptFriendRequest(messageId, completion: { (error: NSError?) in
                    if (error == nil) {
                        pushNotificatoinRef.child("\(userId)/\(self.messageId)/processed").setValue(true)
                        Log.info("accpeted successfully")
                    }
                })
                
                break
            case .Reject:
                Friend.rejectFriendRequest(messageId, completion: { (error: NSError?) in
                    if (error == nil) {
                        pushNotificatoinRef.child("\(userId)/\(self.messageId)/processed").setValue(true)
                        Log.info("rejected successfully")
                    }
                })
                break
            case .Cancel:
                Log.info("friend request type should not have cancel action")
                break
            }
            
        } else if type == .WorkoutInviteReceived {
            switch action {
            case .Accept:
                Invite.acceptWorkoutInvite(associatedId!, workoutTime: timeStamp!, completion: { (error: NSError?) in
                    pushNotificatoinRef.child("\(userId)/\(self.messageId)/processed").setValue(true)
                    Log.info("accepted successfully")

                })
                
                break
            case .Reject:
                Invite.rejectWorkoutInvite(messageId, completion: { (error: NSError?) in
                    pushNotificatoinRef.child("\(userId)/\(self.messageId)/processed").setValue(true)
                    Log.info("rejected successfully")
                })
                
                break
            case .Cancel:
                break
            }
        
        
        }

    }
    
    func setType(_type: String) {
        type = InboxMessage.inboxMessageMap[_type]!
        switch type {
        case .FriendRequestReceived:
            content = "sent you a friend request"
            break
        case .FriendRequestAccepted:
            content = "is now your friend"
            break
        case .FriendRequestRejected:
            content = "rejected your friend request"
            break
        case .WorkoutInviteAccepted:
            content = "accepted your workout invitation"
            break
        case .WorkoutInviteCanceled:
            content = "rejected your workout invitation"
            break
        case .WorkoutInviteReceived:
            content = "sent you a workout invitation"
            break
        case .WorkoutInviteRejected:
            content = "rejected your workout invitation"
            break
        }
    }
    
    class func test() {
        
        // qALhTBIB1GX37OY0nLcZ369RlY52
        inboxMessageRef.child("qALhTBIB1GX37OY0nLcZ369RlY52").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            print(snapshot)
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
//    func saveToBackend() {
//        switch type {
//        case .FriendRequest:
//            // friend request save procedure
//            break
//        case .Invitation:
//            // invitation save procedure
//            break
//        default:
//            Log.info("undefied inbox message type")
//        }
//    }
}