//
//  InviteMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteMainVC: UITableViewController {
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var gymButton: UIButton!
    var sendButton:UIButton!
    
    var sendButtonHeight : CGFloat = 50.0
    var showDatePicker = false
    var showPlan = false
    var seg: UISegmentedControl!
    var segViews: [UIView]!
    
    var time: NSDate!
    var gym: Gym!
    var sendTo: Int!
    var sent = false
    
    var tintColor = ColorScheme.sharedInstance.buttonTint
    var darkText = ColorScheme.sharedInstance.darkText
    var greyText = ColorScheme.sharedInstance.greyText
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load default gym, show on gym label
        
        //default time
        time = NSDate()
        sendTo = 2
        setSendButton()
        setDate()
        setButtons()
        
        if gym != nil {
            enableSendButton()
        }
    }
    override func viewWillAppear(animated: Bool) {
        self.sendButton.hidden = false

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToInviteMainVC (segue: UIStoryboardSegue) {
        if gym != nil {
            enableSendButton()
        }
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func setButtons() {
        dateButton.addShadow()
        gymButton.addShadow()
        dateButton.tintColor = tintColor
        gymButton.tintColor = tintColor
        
        UILabel.appearanceWhenContainedInInstancesOfClasses([UISegmentedControl.self]).numberOfLines = 0
        seg = UISegmentedControl(items: ["Direct Invite", "Broadcast\nBuddies", "Broadcast\nPublic"])
        
        seg.addShadow()
        seg.tintColor = ColorScheme.sharedInstance.greyText
        seg.removeBorders()
        segViews = seg.subviews
        seg.selectedSegmentIndex = sendTo
        seg.momentary = true
        segViews[sendTo].tintColor = tintColor
        seg.selectedSegmentIndex = UISegmentedControlNoSegment
        seg.addTarget(self, action: #selector(InviteMainVC.segmentedControlValueChanged), forControlEvents:.ValueChanged)
    }
    
    func setDate() {
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        datePicker.addTarget(self, action: #selector(InviteMainVC.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        datePicker.minimumDate = NSDate()
        dateButton.setTitle(dateTimeFormatter().stringFromDate(NSDate()), forState: UIControlState.Normal)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InviteMainVC.dismissPicker))
        view.addGestureRecognizer(tap)
    
    }
    
    func setSendButton () {
        sendButton = UIButton(frame: CGRectMake(0, self.view.frame.height - sendButtonHeight, self.view.frame.width, sendButtonHeight))
        sendButton.backgroundColor = greyText
        sendButton.setTitle("Send", forState: UIControlState.Normal)
        sendButton.addTarget(self, action:#selector(self.sendButtonClicked), forControlEvents: .TouchUpInside)
        self.navigationController!.view.addSubview(sendButton)
        sendButton.enabled = false
    }
    
    func enableSendButton() {
        sendButton.backgroundColor = tintColor
        sendButton.enabled = true
    }
    
    func sendButtonClicked() {
        //send out invitation
//        sendInvitation(time: time, loc: gym, audience: sendTo, completion: ({
//            
//        })
//        )
        sent = true
        self.dismissViewControllerAnimated(true, completion: nil)
        print("Button Clicked")
    }
    
    func dismissPicker () {
        tableView.beginUpdates()
        showDatePicker = false
        tableView.endUpdates()
    }
    
    @IBAction func onDateButton(sender: AnyObject) {
        tableView.beginUpdates()
        showDatePicker = true
        tableView.endUpdates()
    }
    
    
    func datePickerValueChanged(sender: UIDatePicker) {
        print("date picker changed")
        dateButton.setTitle(dateTimeFormatter().stringFromDate(sender.date), forState: UIControlState.Normal)
    }
    
    func segmentedControlValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.performSegueWithIdentifier("toBuddySegue", sender: self)
        }
        
        for (index, _) in segViews.enumerate() {
            if index == sender.selectedSegmentIndex {
                //segViews[index].backgroundColor = sender.tintColor
                segViews[index].tintColor = ColorScheme.sharedInstance.buttonTint
                sender.selectedSegmentIndex = UISegmentedControlNoSegment
            }else {
                //segViews[index].backgroundColor = sender.backgroundColor
                segViews[index].tintColor = sender.tintColor
            }
        }
        
        

    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 8
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 2 && !showDatePicker {
            return 0
        }
        if indexPath.row == 3 && !showPlan {
            return 0
        }
        return  super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        
        if indexPath.row == 7 {
            //set as center
            seg.frame = CGRectMake((self.tableView.frame.width - gymButton.frame.width)/2.0, (super.tableView(tableView, heightForRowAtIndexPath: indexPath) - 50)/2.0, gymButton.frame.width, 50)
            cell.addSubview(seg)
        }
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    
//    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.sendButton.hidden = true
        if let desVC = segue.destinationViewController as? MeBuddiesVC {
            desVC.inviting = true
        }
    }
 

}


