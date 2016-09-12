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
    var recipientScreenName: String
    var isNew: Bool
    private let ref:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_conversations")
    
    init(conversationId: String, lastRecord: String, initWithRecipientIdandName recipientId: String, recipientScreenName: String, isNew: Bool) {
        self.conversationId = conversationId
        self.lastRecord = lastRecord
        self.recipientId = recipientId
        self.recipientScreenName = recipientScreenName
        self.isNew = isNew
    }
    
    func update(lastRecord: String, isNew: Bool) {
        self.lastRecord = lastRecord
        self.isNew = isNew
    }
    
    class func getMyActiveConversationList() {
        if let user = User.currentUser {
            let userId = user.userId
            
        
        }
    
    
    }


}