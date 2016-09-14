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
    @IBOutlet var titleView: UIView!
    
    //the selected plan
    var plan = Plan()
    var cats = ["Shoulder", "Arms", "Chest", "Abs", "Back", "Leg", "Cardio"]
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupVisual()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupVisual() {
        titleView.backgroundColor = ColorScheme.s3Bg
        self.view.backgroundColor = ColorScheme.s3Bg
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
            desVC.plan = sender as! Plan
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
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //should be plans[indexpath.row] when pulling actual data
        self.performSegueWithIdentifier("toInviteDetailSegue", sender: plan)
    }
}
