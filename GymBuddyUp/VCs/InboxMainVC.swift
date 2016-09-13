//
//  InboxMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import HMSegmentedControl
import Firebase
import FirebaseDatabase

class InboxMainVC: UIViewController {
    enum TabStates {
        case Invitaions
        case BuddyRequests
        case Chat
    }
    
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var tableView: UITableView!
    lazy private var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    lazy private var userConversationRef: FIRDatabaseReference! = FIRDatabase.database().reference().child("user_conversation")
    lazy private var pushNotificatoinRef: FIRDatabaseReference! = FIRDatabase.database().reference().child("user_notification")
    var actions = [String] (count: 3, repeatedValue: "Action")
    var messages = [String](count: 10, repeatedValue: "Test")
    var conversations = [Conversation]()
    var inboxMessages = [String]()
    var showInvites = true
    var tabState: TabStates = .Invitaions
    var inboxMessageDict = [String: InboxMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
        addSegControl(segView)
        setupVisual()
        setupDataListener()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func testBarButtonClick(sender: AnyObject) {
        Friend.sendFriendRequest("VYkFlp8LyMeIF2abQCbPAh6nuMD3") { (error: NSError?) in
            if (error != nil) {
            
            
            }
        }
    }
    
    func setupDataListener() {
        guard let userId = User.currentUser?.userId else {return}
        userConversationRef.child(userId).observeEventType(.ChildAdded, withBlock: {(snapshot) in
            let conversationId = snapshot.key
            guard let recipientId = snapshot.value?["recipient_id"] as? String, recipientName = snapshot.value?["recipient_name"] as? String else {return}
            Log.info("recipientName \(recipientName)")
            let lastRecord = snapshot.value!["last_record"] as! String
            let _ = snapshot.value!["createdAt"] as! String
            var isNew = false
            if let _isNew = snapshot.value?["isNew"] as? Int where _isNew == 1 {
                    isNew = true
            }
            let conversation = Conversation(conversationId: conversationId, lastRecord: lastRecord, initWithRecipientIdandName: recipientId, recipientScreenName: recipientName, isNew: isNew)
            self.conversations.append(conversation)
            self.tableView.reloadData()
        }) { (error) in
            Log.info("asdasdasdasd")
        }
        
        userConversationRef.child(userId).observeEventType(.ChildChanged, withBlock: {(snapshot) in
            let conversationId = snapshot.key
            let lastRecord = snapshot.value!["last_record"] as! String
            var isNew = false
            if let _isNew = snapshot.value?["isNew"] as? Int where _isNew == 1 {
                isNew = true
            }
            let _ = self.conversations.indexOf({ (conversation: Conversation) -> Bool in
                if conversation.conversationId == conversationId {
                    conversation.update(lastRecord, isNew: isNew)
                    return true
                }
                return false
            })
            self.tableView.reloadData()
        }) { (error) in
            Log.info("\(error.localizedDescription)")
        }
    
        pushNotificatoinRef.child(userId).observeEventType(.ChildAdded, withBlock: {(snapshot) in
            print("inboxmessage got!")
            if (!snapshot.exists()) {
                return
            }
            guard let type = snapshot.value?["type"] as? String,
                isProcessed = snapshot.value?["processed"] as? Bool,
                isIgnored = snapshot.value?["ignored"] as? Bool,
                senderId = snapshot.value?["sender"] as? String,
                _ = snapshot.value?["timestamp"] as? Int
            else {return}
            let messageId = snapshot.key
            let message = InboxMessage(_messageId: snapshot.key, _type: type, _senderId: senderId, _associatedId: nil)
            message.isProcessed = isProcessed
            message.isIgnore = isIgnored
            self.inboxMessageDict[messageId] = message
            self.inboxMessages.append(messageId)
        
        })
        
        pushNotificatoinRef.child(userId).observeEventType(.ChildChanged, withBlock: {(snapshot) in
            print("inboxmessage change detected")
            if (!snapshot.exists()) {
                return
            }
            
            guard let type = snapshot.value?["type"] as? String,
                isProcessed = snapshot.value?["processed"] as? Bool,
                isIgnored = snapshot.value?["ignored"] as? Bool,
                _ = snapshot.value?["sender"] as? String,
                _ = snapshot.value?["timestamp"] as? Int
                else {return}
            
            let messageId = snapshot.key
            let message = self.inboxMessageDict[messageId]
            message?.setType(type)
            message?.isProcessed = isProcessed
            message?.isIgnore = isIgnored
            self.tableView.reloadData()
        
        })
    
    }

    func setupVisual() {
        tableView.backgroundColor = ColorScheme.s3Bg
        segView.backgroundColor = ColorScheme.s4Bg
    }
    
    func addSegControl (view: UIView) {
        let segControl = HMSegmentedControl(sectionTitles: ["Invitations", "Buddy Requests", "Messages"])
        segControl.customize()
        segControl.backgroundColor = ColorScheme.s4Bg
        segControl.frame = CGRectMake(0, 0, self.view.frame.width, view.frame.height)
        view.addSubview(segControl)
        segControl.addTarget(self, action: #selector(onSegControl(_:)), forControlEvents: .ValueChanged)
    }
    
    func setupTableView () {
        tableView.registerNib(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "ConversationCell")
        tableView.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func onSegControl (sender: HMSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tabState = .Invitaions
            break
        case 1:
            tabState = .BuddyRequests
            break
        case 2:
            tabState = .Chat
            break
        default:
            tabState = .Invitaions
            break
        }
        
        tableView.reloadData()
    }
    
    func onAcceptButton (sender: UIButton) {
        let index = sender.tag
        let inboxMessageId = inboxMessages[index]
        let inboxMessage = inboxMessageDict[inboxMessageId]
        inboxMessage?.process(.Accept)
    }
    
    func onCancelButton (sender: UIButton) {
        let index = sender.tag
        let inboxMessageId = inboxMessages[index]
        let inboxMessage = inboxMessageDict[inboxMessageId]
        inboxMessage?.process(.Reject)
    }
    
    @IBAction func onClearButton(sender: AnyObject) {
        messages.removeAll()
        tableView.reloadData()
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navVC = segue.destinationViewController as? UINavigationController, let desVC = navVC.topViewController as? DiscoverDetailVC {
            desVC.plan = Plan()
            //desVC.event = PublishedWorkout
        }
    }
    

}

extension InboxMainVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        //        if tabState == .Invitaions || tabState == .BuddyRequests {
//            return 2
//        } else {
//            return 1
//        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tabState == .Invitaions || tabState == .BuddyRequests {
            if section == 0 {
                return inboxMessages.count
            } else {
                return inboxMessages.count
            }
        }  else {
            return conversations.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tabState == .Invitaions {
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            cell.reset()
            if indexPath.section == 0 {
                cell.message = actions[indexPath.row]
                cell.showButtons()
                //get cancel/accept button from cell.message
                //cell.acceptButton.tag = indexPath.row
                cell.acceptButton.addTarget(self, action: #selector(InboxMainVC.onAcceptButton), forControlEvents: .TouchUpInside)
                //cell.cancelButton.tag = indexPath.row
                cell.cancelButton.addTarget(self, action: #selector(InboxMainVC.onCancelButton), forControlEvents: .TouchUpInside)
            }else {
                cell.message = messages[indexPath.row]
            }
            if showInvites {
                cell.showTime()
                cell.showIndicator(true)
            }
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        
        } else if tabState == .BuddyRequests {

            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            cell.reset()
            if indexPath.section == 0 {
                let inboxMessageId = inboxMessages[indexPath.row]
                let inboxMessage = inboxMessageDict[inboxMessageId]
                cell.message = inboxMessage?.senderId
                cell.statusLabel.text = inboxMessage?.content
                if let isProcessed = inboxMessage?.isProcessed where isProcessed == true {
                    cell.showButtons()
                }
                //get cancel/accept button from cell.message
                cell.acceptButton.tag = indexPath.row
                cell.acceptButton.addTarget(self, action: #selector(InboxMainVC.onAcceptButton), forControlEvents: .TouchUpInside)
                cell.cancelButton.tag = indexPath.row
                cell.cancelButton.addTarget(self, action: #selector(InboxMainVC.onCancelButton), forControlEvents: .TouchUpInside)
            } else {
//                cell.message = messages[indexPath.row]
            }
            
            if showInvites {
                cell.showTime()
                cell.showIndicator(true)
            }
            
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath) as! ConversationCell
            let index = indexPath.row
            let conversation = conversations[index]
            cell.screenNameLabel.text = conversation.recipientScreenName
            if conversation.isNew == true {
                cell.badgeLabel.backgroundColor = UIColor.redColor()
            } else {
                cell.badgeLabel.backgroundColor = UIColor.clearColor()
            }
            cell.lastRecordLabel.text = conversation.lastRecord
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tabState == .Invitaions {
            self.performSegueWithIdentifier("toPlanDetailSegue", sender: indexPath.section == 0 ? actions[indexPath.row] : messages[indexPath.row])
        
        } else if tabState == .BuddyRequests {
//            self.performSegueWithIdentifier("toBuddyProfileSegue", sender: indexPath.section == 0 ? actions[indexPath.row] : messages[indexPath.row])
        
        } else {
            let index = indexPath.row
            let conversation = conversations[index]
            if let currentUserId = User.currentUser?.userId,
                    senderName = User.currentUser?.screenName {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ConversationCell
                cell.badgeLabel.backgroundColor = UIColor.clearColor()
                conversation.isNew = false
                let recipientUserId = conversation.recipientId
                let recipientScreenName = conversation.recipientScreenName
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                let chatVC = storyboard.instantiateViewControllerWithIdentifier("chatVC") as! ChatViewController
                chatVC.setup(currentUserId, senderName: senderName, setupByRecipientId: recipientUserId, recipientName: recipientScreenName)
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        
        }
        
    }
    
}