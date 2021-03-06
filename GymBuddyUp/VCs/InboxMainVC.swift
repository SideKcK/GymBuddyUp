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
import Alamofire
import AlamofireImage
import SwiftDate

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
    var inboxBuddies = [String]()
    var inboxInvitations = [String]()
    var showInvites = true
    var tabState: TabStates = .Invitaions
    var inboxBuddyDict = [String: InboxMessage]()
    var inboxInvitationDict = [String: InboxMessage]()
    var segControl: HMSegmentedControl!
    let timeStampFormatter = NSDateFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
        addSegControl(segView)
        setupVisual()
        setupDataListener()
        setupMisc()
        // Do any additional setup after loading the view.
    }
    
    func setupMisc() {
        timeStampFormatter.timeZone = NSTimeZone.localTimeZone()
        timeStampFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    
    
    @IBAction func testBarButtonClick(sender: AnyObject) {
        Log.info("test button clicked")
        Friend.sendFriendRequest("wz5xp2adjfM5MEUC5BtGNIxATIf2") { (error: NSError?) in
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
            guard let recipientId = snapshot.value?["recipient_id"] as? String, recipientName = snapshot.value?["recipient_name"] as? String else {return}
            let lastRecord = snapshot.value!["last_record"] as! String
            let _ = snapshot.value!["createdAt"] as! String
            var isNew = false
            if let _isNew = snapshot.value?["isNew"] as? Int where _isNew == 1 {
                isNew = true
            }

            let isInCurrentList = self.conversations.indexOf({ (conversation: Conversation) -> Bool in
                if conversation.conversationId == conversationId {
                    conversation.update(lastRecord, isNew: isNew)
                    return true
                }
                return false
            })
            
            if isInCurrentList == nil {
                let conversation = Conversation(conversationId: conversationId, lastRecord: lastRecord, initWithRecipientIdandName: recipientId, recipientScreenName: recipientName, isNew: isNew)
                self.conversations.append(conversation)
            }
            
            self.tableView.reloadData()
        }) { (error) in
            Log.info("\(error.localizedDescription)")
        }
    
        let pushNotificationQuery = pushNotificatoinRef.child(userId).queryOrderedByChild("timestamp")
        pushNotificationQuery.observeEventType(.ChildAdded, withBlock: {(snapshot) in
            print("inboxmessage got!")
            if (!snapshot.exists()) {
                return
            }
            guard let type = snapshot.value?["type"] as? String,
                isProcessed = snapshot.value?["processed"] as? Bool,
                isIgnored = snapshot.value?["ignored"] as? Bool,
                senderId = snapshot.value?["sender"] as? String,
                senderName = snapshot.value?["sender_name"] as? String,
                timeStamp = snapshot.value?["timestamp"] as? Double
            else {return}
            let messageId = snapshot.key
            let associatedId = snapshot.value?["workout_invite_id"] as? String
            let message = InboxMessage(_messageId: snapshot.key, _type: type, _senderId: senderId, _associatedId: associatedId, _senderName: senderName, _timeStamp: timeStamp)
            message.isProcessed = isProcessed
            message.isIgnore = isIgnored
            
            switch message.type {
            case .FriendRequestAccepted, .FriendRequestReceived, .FriendRequestRejected:
                self.inboxBuddyDict[messageId] = message
                self.inboxBuddies.append(messageId)
                break
            case .WorkoutInviteAccepted, .WorkoutInviteCanceled, .WorkoutInviteReceived, .WorkoutInviteRejected:
                self.inboxInvitationDict[messageId] = message
                self.inboxInvitations.append(messageId)
                break
            }
            
            self.tableView.reloadData()
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
            
            let inboxType = InboxMessage.inboxMessageMap[type]!
            let messageId = snapshot.key
            var message: InboxMessage?
            
            switch inboxType {
            case .FriendRequestAccepted,.FriendRequestReceived,.FriendRequestRejected:
                message = self.inboxBuddyDict[messageId]
                break
            case .WorkoutInviteAccepted, .WorkoutInviteCanceled, .WorkoutInviteReceived, .WorkoutInviteRejected:
                message = self.inboxInvitationDict[messageId]
                break
            }
            
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
        segControl = HMSegmentedControl(sectionTitles: ["Invitations", "Buddy Requests", "Messages"])
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
    
    
    func onBuddyAcceptButton (sender: UIButton) {
        let index = sender.tag
        let inboxMessageId = inboxBuddies.reverseGet(index)
        let inboxMessage = inboxBuddyDict[inboxMessageId]
        inboxMessage?.process(.Accept)
    }
    
    func onBuddyRejectButton (sender: UIButton) {
        let index = sender.tag
        let inboxMessageId = inboxBuddies.reverseGet(index)
        let inboxMessage = inboxBuddyDict[inboxMessageId]
        inboxMessage?.process(.Reject)
    }
    
    func onInvitationAcceptButton (sender: UIButton) {
        let index = sender.tag
        Log.info("onInvitationAcceptButton index = \(index)")
        let inboxMessageId = inboxInvitations.reverseGet(index)
        let inboxMessage = inboxInvitationDict[inboxMessageId]
        Log.info("accepted message id = \(inboxMessage?.messageId)")
        inboxMessage?.process(.Accept)
    }
    
    func onInvitationRejectButton (sender: UIButton) {
        let index = sender.tag
        Log.info("onInvitationRejectButton index = \(index)")
        let inboxMessageId = inboxInvitations.reverseGet(index)
        let inboxMessage = inboxInvitationDict[inboxMessageId]
        Log.info("rejected message id = \(inboxMessage?.messageId)")
        inboxMessage?.process(.Reject)
    }
    
    func onInvitationCancelButton (sender: UIButton) {
        let index = sender.tag
        Log.info("onInvitationCancelButton index = \(index)")
        let inboxMessageId = inboxInvitations.reverseGet(index)
        let inboxMessage = inboxInvitationDict[inboxMessageId]
        Log.info("cancelled message id = \(inboxMessage?.messageId)")
        inboxMessage?.process(.Cancel)
    }
    
    @IBAction func onClearButton(sender: AnyObject) {
        messages.removeAll()
        tableView.reloadData()
    }

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navVC = segue.destinationViewController as? UINavigationController, let desVC = navVC.topViewController as? DiscoverDetailVC {
            guard let senderDict = sender as? [String : AnyObject] else {return}
            desVC.event = senderDict["invite"] as! Invite
            desVC.plan = senderDict["plan"] as! Plan
        }
    }
    

}

extension InboxMainVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    // TODO: pin to the top for messages that need to be resolved
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tabState {
        case .Invitaions:
            return inboxInvitations.count
        case .BuddyRequests:
            return inboxBuddies.count
        case .Chat:
            return conversations.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tabState == .Invitaions {
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            cell.reset()
            if indexPath.section == 0 {
                let index = indexPath.row
                let inboxMessageId = inboxInvitations.reverseGet(index)
                guard let inboxMessage = inboxInvitationDict[inboxMessageId] else {return cell}
                cell.bindedUserId = inboxMessage.senderId
                cell.nameLabel.text = inboxMessage.senderName
                cell.statusLabel.text = inboxMessage.content
                
                if let timestamp = inboxMessage.timeStamp {
                    let timeLabelString = timeStampFormatter.stringFromDate(timestamp)
                    if let offsetedTime = timeStampFormatter.dateFromString(timeLabelString) {
                        cell.timeLabel.text = NSDate.timeAgoSinceDate(offsetedTime, numericDates: false)
                    }
                }
                
                Log.info("invitation type = \(inboxMessage.type) isProcessed = \(inboxMessage.isProcessed)")
                if inboxMessage.isProcessed == false && inboxMessage.type == .WorkoutInviteReceived {
                    cell.showButtons()
                }
                //get cancel/accept button from cell.message
                cell.acceptButton.tag = indexPath.row
                cell.acceptButton.addTarget(self, action: #selector(onInvitationAcceptButton), forControlEvents: .TouchUpInside)
                cell.cancelButton.tag = indexPath.row
                cell.cancelButton.addTarget(self, action: #selector(onInvitationRejectButton), forControlEvents: .TouchUpInside)
            }else {
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
                let index = indexPath.row
                let inboxMessageId = inboxBuddies.reverseGet(index)
                guard let inboxMessage = inboxBuddyDict[inboxMessageId] else {return cell}
                cell.bindedUserId = inboxMessage.senderId
                cell.nameLabel.text = inboxMessage.senderName
                cell.statusLabel.text = inboxMessage.content
                if let timestamp = inboxMessage.timeStamp {
                    let timeLabelString = timeStampFormatter.stringFromDate(timestamp)
                    let offsetedTime = timeStampFormatter.dateFromString(timeLabelString)
                    if let elapsedTimeString = offsetedTime?.toNaturalString(NSDate()) {
                        cell.timeLabel.text = elapsedTimeString + " ago"
                    }
                }
                if inboxMessage.isProcessed == false && inboxMessage.type == .FriendRequestReceived {
                    cell.showButtons()
                }
                //get cancel/accept button from cell.message
                cell.acceptButton.tag = indexPath.row
                cell.acceptButton.addTarget(self, action: #selector(onBuddyAcceptButton), forControlEvents: .TouchUpInside)
                cell.cancelButton.tag = indexPath.row
                cell.cancelButton.addTarget(self, action: #selector(onBuddyRejectButton), forControlEvents: .TouchUpInside)
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
            cell.selectionStyle = .Gray
            let index = indexPath.row
            let conversation = conversations[index]
            let asyncId = conversation.conversationId
            cell.asyncId = conversation.conversationId
            cell.screenNameLabel.text = conversation.recipientScreenName
            
            if let user = UserCache.sharedInstance.cache[conversation.recipientId] {                
                if let photoURL = user.photoURL where user.cachedPhoto == nil {
                    let request = NSMutableURLRequest(URL: photoURL)
                    cell.avatarImage.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "dumbbell"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                        if asyncId == cell.asyncId {
                            cell.avatarImage.image = response.result.value
                            user.cachedPhoto = response.result.value
                        }
                    }
                } else {
                    cell.avatarImage.image = user.cachedPhoto
                }
            } else {
                User.getUserArrayFromIdList([conversation.recipientId]) { (users: [User]) in
                    if asyncId == cell.asyncId {
                        let user = users[0]
                        UserCache.sharedInstance.cache[conversation.recipientId] = user
                        if let photoURL = user.photoURL {
                            let request = NSMutableURLRequest(URL: photoURL)
                            cell.avatarImage.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "dumbbell"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                                if asyncId == cell.asyncId {
                                    cell.avatarImage.image = response.result.value
                                    user.cachedPhoto = response.result.value
                                }
                            }
                            
                        }
                    }
                }
            }

            
            
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
            let inboxMessageId = inboxInvitations[indexPath.row]
            let inboxMessage = inboxInvitationDict[inboxMessageId]
            guard let workoutId = inboxMessage?.associatedId else {return}
            Invite.getWorkoutInviteById(workoutId, completion: { (error: NSError?, invite: Invite?) in
                if error == nil {
                    guard let _invite = invite else {return}
                    _invite.id = workoutId
                    Library.getPlanById(_invite.planId, completion: { (plan, error) in
                        if error != nil {
                            Log.error(error.debugDescription)
                        }else {
                            guard let _plan = plan else {return}
                            Log.info("Got both invitation and plan")
                            self.performSegueWithIdentifier("toPlanDetailSegue", sender: ["invite" : _invite, "plan": _plan])
                        }
                    })
                } else {
                    Log.info("Can't access this invitation: \(error?.localizedDescription)")
                }
            })
        } else if tabState == .BuddyRequests {
//            self.performSegueWithIdentifier("toBuddyProfileSegue", sender: indexPath.section == 0 ? actions[indexPath.row] : messages[indexPath.row])
        
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.selected = false
            Log.info("did select chat session")
            let index = indexPath.row
            let conversation = conversations[index]
            if let currentUserId = User.currentUser?.userId,
                    senderName = User.currentUser?.screenName {
                Log.info("unwrap required parameters")
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