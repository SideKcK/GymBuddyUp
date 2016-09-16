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
    var selected = -1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVisual()
        setupDatepicker()
        setupTableView()
        nextButton.enabled = false
        nextButton.backgroundColor = ColorScheme.g3Text

    }

    override func viewWillAppear(animated: Bool) {
        if let row = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(row, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToInvitePlanVC (segue: UIStoryboardSegue) {

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
    
    @IBAction func onDatePicker(sender: UIDatePicker) {
        let date = sender.date
        //refresh plans
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func addPlan (sender: UIButton) {
        self.performSegueWithIdentifier("toPlanLibSegue", sender: self)
    }
    @IBAction func onNextButton(sender: AnyObject) {
        if selected == 0 {
            self.performSegueWithIdentifier("toNoPlanCatSegue", sender: self)
        }else {
            self.performSegueWithIdentifier("toInviteDetailSegue", sender: self)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteMainVC {
            desVC.plan = plans[selected - 1]
        }
        if let navVC = segue.destinationViewController as? PlanLibNavVC, let desVC = navVC.topViewController as? PlanLibVC{
            desVC.from = self
        }
    }
    

}

extension InvitePlanVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + plans.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("noPlanCell", forIndexPath: indexPath) as! InviteNoPlanCell
            
            return cell
        }else if indexPath.row == plans.count + 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addPlanCell", forIndexPath: indexPath) as! InviteAddPlanCell
            cell.addButton.addTarget(self, action: #selector(InvitePlanVC.addPlan(_:)), forControlEvents: .TouchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
            cell.userInteractionEnabled = true
            cell.plan = plans[indexPath.row - 1]
            //remove shadow
            cell.borderView.clipsToBounds = true
            cell.showDateView()

            //disable the cell
//            cell.userInteractionEnabled = false
//            cell.borderView.alpha = 0.5
            
            //show these views if the invitation is sent and not selectable
//            cell.showLocView()
//            cell.showTimeView()
//            cell.showStatusView()

            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        nextButton.enabled = true
        nextButton.backgroundColor = ColorScheme.p1Tint
        selected = indexPath.row
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? InviteNoPlanCell {
            cell.borderView.layer.borderWidth = 2.0
            
        }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? WorkoutCell {
            cell.borderView.layer.borderWidth = 2.0
            
        }

    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? InviteNoPlanCell {
            cell.borderView.layer.borderWidth = 0.0
            
        }
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? WorkoutCell {
            cell.borderView.layer.borderWidth = 0.0
            
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            if let cell = cell as? InviteNoPlanCell {
                cell.borderView.layer.borderWidth = indexPath.row == selected ? 2.0 : 0.0
                
            }
            if let cell = cell as? WorkoutCell {
                cell.borderView.layer.borderWidth = indexPath.row == selected ? 2.0 : 0.0
                
            }
        
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
    }
}
