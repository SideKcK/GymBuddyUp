//
//  MeBuddiesVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MeBuddiesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var inviting = false
    var buddies = ["Jesiah", "You", "Aaron"]//TODO change to User
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteMainVC {
            desVC.seg.setTitle(sender as? String, forSegmentAtIndex: 0)
        }
    }
 

}

extension MeBuddiesVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCell", forIndexPath: indexPath) as! BuddyCell
        cell.buddy = buddies[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if inviting {
            self.performSegueWithIdentifier("unwindToInviteMainVC", sender: buddies[indexPath.row])
        }
    }
}
