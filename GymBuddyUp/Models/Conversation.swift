//
//  Conversation.swift
//  GymBuddyUp
//
//  Created by YiHuang on 9/1/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Conversation {
    var conversationId: String
    var lastRecord: String
    var recipientId: String
    private let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_conversations")
    
    init(conversationId: String, lastRecord: String, recipientId: String) {
        self.conversationId = conversationId
        self.lastRecord = lastRecord
        self.recipientId = recipientId
    }
    
    class func getMyActiveConversationList() {
        if let user = User.currentUser {
            let userId = user.userId
            
        
        }
    
    
    }


}