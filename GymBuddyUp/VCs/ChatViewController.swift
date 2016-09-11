//
//  ChatViewController.swift
//  GymBuddyUp
//
//  Created by YiHuang on 9/1/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

import JSQMessagesViewController
import Firebase
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    private let ref:FIRDatabaseReference! = FIRDatabase.database().reference()
    private let chatRoomRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("chat_room")
    private let userConversationRef:FIRDatabaseReference! = FIRDatabase.database().reference().child("user_conversation")

    let dateFormatter = NSDateFormatter()

    var recipientId: String?
    var recipientScreenName: String?
    var conversationId: String?
    
    // change it to false when deployed
    let inDebug = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("chatview viewDidLoad")
        // Do any additional setup after loading the view.
        
        setupBubbles()
        
        /* just for debug  --------start-------- */
        if inDebug {
            senderId = "jedihy"
            senderDisplayName = "jedihy"
            recipientId = "asdasdasd"
            
            if let rId = recipientId, sId = senderId {
                conversationId = getConversationId(sId, strB: rId)
            }
        }
        /* just for debug  ---------end--------- */
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        observeMessages()
    }
    
    // call setup(senderId, recipientId) when preparing segue
    func setup(senderId:String, senderName: String, setupByRecipientId recipientId: String, recipientName: String?) {
        Log.info("setup ChatVC")
        self.title = recipientName
        self.recipientScreenName = recipientName
        self.senderId = senderId
        self.senderDisplayName = senderName
        self.recipientId = recipientId
        self.conversationId = getConversationId(senderId, strB: recipientId)
        unNewConversation()

    }
    
    private func unNewConversation() {
        if let convsId = self.conversationId {
            let ownConversationRef = userConversationRef.child("\(self.senderId)/\(convsId)/isNew")
            ownConversationRef.setValue(0)
        }
    }
    
    private func getConversationId(strA: String, strB: String) -> String {
        if strA > strB {
            return "\(strA)\(strB)"
        } else {
            return "\(strB)\(strA)"
        }
    }
    
    private func observeMessages() {
        
        if let convsID = conversationId {
            let messageRef = chatRoomRef.child("\(convsID)")
            let messagesQuery = messageRef.queryLimitedToLast(25)
            messagesQuery.observeEventType(.ChildAdded, withBlock: {(snapshot) in
                var createAt = NSDate()
                let id = snapshot.value!["senderId"] as! String
                let text = snapshot.value!["text"] as! String
                if let timeStamp = snapshot.value!["createAt"] as? String {
                    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    if let _createAt = self.dateFormatter.dateFromString(timeStamp) {
                        createAt = _createAt.toLocalTime()
                    }
                }
                self.addMessage(id, text: text, date: createAt)
                self.unNewConversation()
                self.finishReceivingMessage()
            }) { (error) in
                Log.info("asdasdasdasd")
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func didPressSendButton(button: UIButton!,
                                     withMessageText text: String!,
                                     senderId: String!,
                                     senderDisplayName: String!, date: NSDate!) {
        
        if let  convsID = conversationId,
                rcScreenName = recipientScreenName,
                reId = recipientId,
                sndId = senderId,
                sndScreenName = senderDisplayName
        {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let timeStamp = dateFormatter.stringFromDate(date!.toGlobalTime())
            
            let messageRef = chatRoomRef.child("\(convsID)")
            let ownConversationRef = userConversationRef.child("\(senderId)/\(convsID)")
            let peerConversationRef = userConversationRef.child("\(reId)/\(convsID)")
            let ownConversationItem = [
                "recipient_id": reId,
                "recipient_name": rcScreenName,
                "last_record": text,
                "createdAt": timeStamp,
                "isNew": 1
            ]
            let peerConversationItem = [
                "recipient_id": sndId,
                "recipient_name": sndScreenName,
                "last_record": text,
                "createdAt": timeStamp,
                "isNew": 1
            ]
            
            print(ownConversationItem)
            print(peerConversationItem)
            ownConversationRef.setValue(ownConversationItem)
            peerConversationRef.setValue(peerConversationItem)
            
            
            let itemRef = messageRef.childByAutoId()
            let messageItem = [ // 2
                "text": text,
                "senderId": senderId,
                "createAt": timeStamp
            ]
            itemRef.setValue(messageItem) // 3
            
            
            finishSendingMessage()
        } else {
            return
        }

    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func addMessage(id: String, text: String, date: NSDate) {
        let message = JSQMessage(senderId: id, senderDisplayName: "", date: date, text: text)
        messages.append(message)
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            let message = self.messages[indexPath.item]
            if message.date.timeIntervalSinceDate(previousMessage.date) / 60 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }

    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString {
        let message = self.messages[indexPath.item]
        if indexPath.item == 0 {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if message.date.timeIntervalSinceDate(previousMessage.date) / 60 > 1 {
                return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
            }
        }
        return NSAttributedString()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
