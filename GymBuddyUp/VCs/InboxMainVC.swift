//
//  InboxMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import HMSegmentedControl

class InboxMainVC: UIViewController {
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var actions = [String] (count: 3, repeatedValue: "Action")
    var messages = [String](count: 10, repeatedValue: "Test")
    var conversatoins = [Conversation]()
    var showInvites = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
        addSegControl(segView)
        setupVisual()
        // Do any additional setup after loading the view.
    }

    func setupVisual() {
        tableView.backgroundColor = ColorScheme.s3Bg
        segView.backgroundColor = ColorScheme.s4Bg
    }
    
    func addSegControl (view: UIView) {
        let segControl = HMSegmentedControl(sectionTitles: ["Workout Invites", "Buddy Requests"])
        segControl.customize()
        segControl.backgroundColor = ColorScheme.s4Bg
        segControl.frame = CGRectMake(0, 0, self.view.frame.width, view.frame.height)
        view.addSubview(segControl)
        segControl.addTarget(self, action: #selector(InboxMainVC.onSegControl(_:)), forControlEvents: .ValueChanged)
    }
    
    func setupTableView () {
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
        showInvites = !showInvites
        tableView.reloadData()
    }
    
    func onAcceptButton (sender: UIButton) {
        let row = sender.tag
        messages.removeAtIndex(row)
        tableView.reloadData()
    }
    
    func onCancelButton (sender: UIButton) {
        let row = sender.tag
        messages.removeAtIndex(row)
        tableView.reloadData()
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
        }
    }
    

}

extension InboxMainVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return actions.count
        }else {
            return messages.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if showInvites {
            self.performSegueWithIdentifier("toPlanDetailSegue", sender: messages[indexPath.row])
        }else {
            self.performSegueWithIdentifier("toBuddyProfileSegue", sender: messages[indexPath.row])
        }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MessageCell {
            cell.borderView.backgroundColor = ColorScheme.greyText
            UIView.animateWithDuration(0.1, delay: 0.3, options: .CurveEaseIn, animations: {
                cell.borderView.backgroundColor = UIColor.whiteColor()
                }, completion: nil)
        }
        
    }
    
}