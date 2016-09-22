//
//  InviteBuddiesVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteBuddiesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var buddies = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        User.currentUser?.getMyFriendList({ (users: [User]) in
            self.buddies = users
            self.tableView.reloadData()
            self.title = "Buddies ("+String(self.buddies.count)+")"
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteMainVC {
            desVC.sendToUser = sender as? User
        }
    }

}

extension InviteBuddiesVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCell", forIndexPath: indexPath) as! BuddyCell
        let index = indexPath.row
        let buddy = buddies[index]
        cell.nameLabel.text = buddy.screenName
        cell.goalLabel.hidden = true
        cell.gymLabel.hidden = true
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("unwindToInviteMainVC", sender: buddies[indexPath.row])
    }
}
