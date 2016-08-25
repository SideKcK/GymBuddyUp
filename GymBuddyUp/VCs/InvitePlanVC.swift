//
//  InvitePlanVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InvitePlanVC: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!

    var plans = [Plan()]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVisual()
        setupDatepicker()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupDatepicker() {
        datePicker.minimumDate = NSDate()
        datePicker.maximumDate = (1.months).fromNow()
    }
    
    func setupVisual() {
        self.view.backgroundColor = ColorScheme.s3Bg
        datePicker.backgroundColor = ColorScheme.s4Bg
        nextButton.backgroundColor = ColorScheme.p1Tint
        nextButton.titleLabel?.textColor = ColorScheme.g4Text
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InvitePlanVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + plans.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("noPlanCell", forIndexPath: indexPath)
            return cell
        }else if indexPath.row == plans.count + 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addPlanCell", forIndexPath: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath)
            return cell
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
}
