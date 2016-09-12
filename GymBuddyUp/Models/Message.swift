//
//  GroupChatMessage.swift
//  Dine
//
//  Created by YiHuang on 3/23/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import Foundation

class Message {
    var activityId: String?
    var messageId: String?
    var senderId: String?
    var screenName: String?
    var senderAvatarPFFile: NSURL?
    var content: String?
    var createdAt: NSDate?
    var isRecentMessage = false
    var createdAtString: String?
    var media: NSURL?
    var mediaType: String?
    
    init (dictionary: NSDictionary) {
        self.messageId = dictionary["messageId"] as? String
        self.senderId = dictionary["senderId"] as? String
        self.screenName = dictionary["screenName"] as? String
        self.content = dictionary["content"] as? String
        self.createdAt = dictionary["createdAt"] as? NSDate
    }
    
    init (activityId: String, senderId: String, screenName: String, content: String){
        self.content = content
        self.screenName = screenName
        self.senderId = senderId
    }
    
    init (activityId: String?, senderId: String?, screenName: String?, content: String?, avatarURL: NSURL?, mediaURL: NSURL?, mediaType: String?) {
        self.activityId = activityId
        self.content = content
        self.screenName = screenName
        self.senderAvatarPFFile = avatarURL
        self.senderId = senderId
        self.media = mediaURL
        self.mediaType = mediaType
    }
    
//    init (pfObject: PFObject) {
//        activityId = pfObject["activityId"] as? String
//        messageId = pfObject["messageId"] as? String
//        senderId = pfObject["senderId"] as? String
//        screenName = pfObject["screenName"] as? String
//        senderAvatarPFFile = pfObject["avatarFile"] as? PFFile
//        content = pfObject["content"] as? String
//        mediaType = pfObject["mediaType"] as? String
//        media = pfObject["media"] as? PFFile
//        createdAt = pfObject.createdAt
//    }
    
    func saveToBackend(successHandler: (()->())?, failureHandler: ((NSError?)->())?) {
        let chat = NSDictionary()
        guard let activityId = activityId, content = content, senderId = senderId, screenName = screenName else {
            failureHandler?(NSError(domain: "need more parameters", code: 1, userInfo: nil))
            return
        }
        
//        chat["activityId"] = activityId
//        chat["content"] = content
//        chat["senderId"] = senderId
//        chat["screenName"] = screenName
        
//        if let avatarPFFile = User.currentUser?.avatarImagePFFile {
//            chat["avatarFile"] = avatarPFFile
//        }
//        
//        if let mediaPFFile = media {
//            chat["media"] = mediaPFFile
//            guard let mediaType = mediaType else {
//                failureHandler?(NSError(domain: "should specify media type", code: 2, userInfo: nil))
//                return
//            }
//            chat["mediaType"] = mediaType
//        }
//        
//        chat.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
//            if success == true && error == nil{
//                successHandler?()
//            } else {
//                failureHandler?(error)
//            }
//        })

    }
    
}
