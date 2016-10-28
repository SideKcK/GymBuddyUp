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
import Alamofire

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
    
    class func sendMessageToUser(recipientId: String, completion: (NSError?) -> Void) {
        User.currentUser?.getTokenForcingRefresh() {idToken, error in
            if error != nil {
                return completion(error)
            }
            
            let parameters = [
                "token": idToken!,
                "operation": "chat_message",
                "recipientId": recipientId
            ]
            
            Alamofire.request(.POST, "https://kr24xu120j.execute-api.us-east-1.amazonaws.com/dev/sidekck-notifications", parameters: parameters, encoding: .JSON)
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


}