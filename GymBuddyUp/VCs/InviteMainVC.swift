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

    var sendButtonHeight : CGFloat = 50.0
    var showDatePicker = false
    var showPlan = false
    var seg: UISegmentedControl!
    var segViews: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSendButton()
        setDate()
        setButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToInviteMainVC (segue: UIStoryboardSegue) {
        
    }
    
    func setButtons() {
        dateButton.addShadow()
        gymButton.addShadow()
        dateButton.tintColor = ColorScheme.sharedInstance.buttonTint
        gymButton.tintColor = ColorScheme.sharedInstance.buttonTint
        
        UILabel.appearanceWhenContainedInInstancesOfClasses([UISegmentedControl.self]).numberOfLines = 0
        seg = UISegmentedControl(items: ["Direct Invite", "Broadcast\nBuddies", "Broadcast\nPublic"])
        
        seg.addShadow()
        seg.tintColor = ColorScheme.sharedInstance.buttonTint
        //seg.selectedSegmentIndex = 2
        segViews = seg.subviews
        seg.momentary = true
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
        let button:UIButton = UIButton(frame: CGRectMake(0, self.view.frame.height - sendButtonHeight, self.view.frame.width, sendButtonHeight))
        button.backgroundColor = UIColor.flatGrayColor()
        button.setTitle("Send", forState: UIControlState.Normal)
        button.addTarget(self, action:#selector(self.buttonClicked), forControlEvents: .TouchUpInside)
        self.navigationController!.view.addSubview(button)
    }
    
    func buttonClicked() {
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
                segViews[index].backgroundColor = sender.tintColor
                segViews[index].tintColor = sender.backgroundColor
                sender.selectedSegmentIndex = UISegmentedControlNoSegment
            }else {
                segViews[index].backgroundColor = sender.backgroundColor
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
        if let desVC = segue.destinationViewController as? MeBuddiesVC {
            desVC.inviting = true
        }
    }
 

}


