//
//  InviteMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteMainVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!

    var time: NSDate!
    var gym: Gym!
    var sendTo = "Direct Invite"
    var plan: Plan!
    var workoutId: String?
    
    var segViews : [UIView]!
    var gymButton : UIButton!
    var showDatePicker = false
    var datePickerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load default gym, show on gym label
        
        //default time
        time = NSDate()
        setupTableView()
        
        if gym != nil {
            enableSendButton()
        }
        setupVisual()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavBarItem () {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(InviteMainVC.cancelInvite))
        navigationItem.leftBarButtonItem = cancelButton
    }
    func cancelInvite() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func setupTableView () {
        tableView.registerNib(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func setupVisual() {
        tableView.backgroundColor = ColorScheme.s3Bg
        sendButton.backgroundColor = ColorScheme.g3Text
    }
    
    
    @IBAction func unwindToInviteMainVC (segue: UIStoryboardSegue) {
        if gym != nil {
            tableView.reloadData()
            enableSendButton()
        }
    }
    
    func enableSendButton() {
        sendButton.backgroundColor = ColorScheme.p1Tint
        sendButton.enabled = true
    }
    
    @IBAction func onSendButton(sender: AnyObject) {
        //send out invitation
        //        sendInvitation(time: time, loc: gym, audience: sendTo, completion: ({
        //
        //        })
        //        )
        self.dismissViewControllerAnimated(true, completion: nil)
        let statusView = StatusView()
        statusView.setMessage("Invitation at Today, 7:30 PM Sent!")
        statusView.displayView()

    }
    

    func segmentedControlValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.performSegueWithIdentifier("toBuddySegue", sender: self)
            sendButton.setTitle("Send", forState: .Normal)
        }else {
            sendButton.setTitle("Broadcast", forState: .Normal)
        }
        
        for (index, _) in segViews.enumerate() {
            if index == sender.selectedSegmentIndex {
                //segViews[index].backgroundColor = sender.tintColor
                segViews[index].tintColor = ColorScheme.p1Tint
                sender.selectedSegmentIndex = UISegmentedControlNoSegment
            }else {
                //segViews[index].backgroundColor = sender.backgroundColor
                segViews[index].tintColor = sender.tintColor
            }
        }
        
    }
    
    func onDateButton(sender: AnyObject) {
        showDatePicker = !showDatePicker
        tableView.beginUpdates()
        datePickerHeight.priority = showDatePicker ? 250 : 999
        tableView.endUpdates()
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //self.sendButton.hidden = true
        
    }
 

}

extension InviteMainVC: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
            cell.plan = plan
            //remove shadow
            cell.borderView.clipsToBounds = true
            cell.borderView.layer.borderWidth = 2.0
            cell.borderView.layer.borderColor = ColorScheme.p1Tint.CGColor
            cell.showDateView()
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InviteDateCell", forIndexPath: indexPath) as! InviteDateCell
            cell.dateButton.addTarget(self, action: #selector(InviteMainVC.onDateButton(_:)), forControlEvents: .TouchUpInside)
            datePickerHeight = cell.datePickerHeight
            return cell
        }
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InviteGymCell", forIndexPath: indexPath) as! InviteGymCell
            if gym != nil {
                cell.gymButton.setTitle(gym.name, forState: .Normal)
            }
            return cell
        }
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InviteToCell", forIndexPath: indexPath) as! InviteToCell
            segViews = cell.segViews
            cell.seg.setTitle(sendTo, forSegmentAtIndex: 0)
            cell.seg.addTarget(self, action: #selector(InviteMainVC.segmentedControlValueChanged), forControlEvents:.ValueChanged)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
        if indexPath.row != 0 {
            cell.backgroundColor = UIColor.clearColor()
        }
        if indexPath.row == 3 {
            let cell = cell as! InviteToCell
            cell.seg.frame = cell.toView.bounds
            cell.toView.addSubview(cell.seg)

        }
    }
    
}

