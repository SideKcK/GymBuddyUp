//
//  InboxMessage.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/27/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Firebase
import FirebaseDatabase

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
    var senderName: String
    var senderAvatarUrl: NSURL?
    var senderAvatarImage: UIImage?

    // create a new InboxMessage
    init(_type: InboxMessageType, _content: String, _senderId: String, _receiverId: String, _associatedId: String?, _senderName: String, _senderAvatarUrl: NSURL?) {
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