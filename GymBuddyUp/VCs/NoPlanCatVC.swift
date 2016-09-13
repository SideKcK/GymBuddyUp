//
//  NoPlanCatVC.swift
//  GymBuddyUp
//
//  Created by you wu on 9/12/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class NoPlanCatVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var cats = ["Shoulder", "Arms", "Chest", "Abs", "Back", "Leg", "Cardio"]
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteMainVC {
            //desVC.plan = sender
        }
        
    }

}

extension NoPlanCatVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("noPlanCatCell", forIndexPath: indexPath) as! InviteNoPlanCatCell
        cell.catLabel.text = cats[indexPath.row] + " Workout"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toInviteDetailSegue", sender: cats[indexPath.row])
    }
}
