//
//  MeFindVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import HMSegmentedControl

class MeFindVC: UIViewController {
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var buddies = ["Jesiah", "You", "Aaron"]//TODO change to User
    var fbNum = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSegControl(segView)
        setupVisual()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "BuddyCardCell", bundle: nil), forCellReuseIdentifier: "BuddyCardCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func setupVisual() {
        segView.backgroundColor = ColorScheme.s3Bg
        tableView.backgroundColor = ColorScheme.s3Bg
    }
    
    func addSegControl (view: UIView) {
        let segControl = HMSegmentedControl(sectionTitles: ["Nearby", "Facebook("+String(fbNum)+")"])
        segControl.customize()
        segControl.frame = CGRectMake(0, 0, self.view.frame.width, view.frame.height)
        view.addSubview(segControl)
        segControl.addTarget(self, action: #selector(MeFindVC.onSegControl(_:)), forControlEvents: .ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func onAddButton (sender: UIButton!) {
        let row = sender.tag
        sender.setTitle("Request Sent", forState: .Normal)
        sender.enabled = false
        //send friend request
    }
    
    func onSegControl (sender: HMSegmentedControl) {
        print("seg control")
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? MeMainVC {
            //for testing
            desVC.user?.screenName = sender as? String
        }
    }
 

}

extension MeFindVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCardCell", forIndexPath: indexPath) as! BuddyCardCell
        cell.buddy = buddies[indexPath.row]
        cell.showDistance()
        cell.showAddButton()
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(MeFindVC.onAddButton(_:)), forControlEvents: .TouchUpInside)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ToBuddyProfileSegue", sender: buddies[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
}
