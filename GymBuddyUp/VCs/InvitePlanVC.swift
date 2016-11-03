//
//  InvitePlanVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import KRProgressHUD

class InvitePlanVC: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!

    var plans = [Plan]()
    var workouts = [ScheduledWorkout]()
    var invites = [Invite]()
    var selectedDate = NSDate()
    var selected = 0
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVisual()
        setupDatepicker()
        setupTableView()
        nextButton.enabled = true
        nextButton.backgroundColor = ColorScheme.p1Tint
        reloadPlans(selectedDate)
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
        reloadPlans(selectedDate)
    }

    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupDatepicker() {
        datePicker.minimumDate = NSDate()
//        datePicker.maximumDate = (1.months).fromNow()
    }
    
    func setupVisual() {
        self.view.backgroundColor = ColorScheme.s3Bg
        datePicker.backgroundColor = ColorScheme.s4Bg
        nextButton.backgroundColor = ColorScheme.p1Tint
        nextButton.titleLabel?.textColor = ColorScheme.g4Text

    }
    
    
    func reloadPlans(date: NSDate) {
        KRProgressHUD.show()
        
        ScheduledWorkout.getScheduledWorkoutsForDate(date) { (workouts) in
            if let planIds = Plan.planIDsWithArray(workouts) {
                Library.getPlansById(planIds, completion: { (plans, error) in
                    if error == nil {
                        self.workouts = workouts
                        self.plans = plans
                        self.tableView.reloadData()
                        self.selected = 0
                    } else {
                        print(error)
                        KRProgressHUD.showError()
                    }
                    
                    KRProgressHUD.dismiss()
                    
                })
            }
        }
    }
    
    
    @IBAction func onDatePicker(sender: UIDatePicker) {
        let date = sender.date
        selectedDate = date
        reloadPlans(date)
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
        if let desVC = segue.destinationViewController as? NoPlanCatVC {
            desVC.date = selectedDate
//            desVC.workoutId = workouts[selected - 1].id
        }
        
        if let desVC = segue.destinationViewController as? InviteMainVC {
            
            desVC.plan = plans[selected - 1]
            desVC.workoutId = workouts[selected - 1].id
            desVC.time = selectedDate
            Log.info("workout Id = \(workouts[selected - 1].id)")
        }
        if let navVC = segue.destinationViewController as? PlanLibNavVC, let desVC = navVC.topViewController as? PlanLibVC{
            navVC.selectedDate = selectedDate
            desVC.from = self
            desVC.selectedDate = selectedDate
        }
    }
}

extension InvitePlanVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + plans.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("enter inviteplan vc")
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("noPlanCell", forIndexPath: indexPath) as! InviteNoPlanCell
            cell.borderView.layer.borderWidth = 2.0
            return cell
        }else if indexPath.row == plans.count + 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("addPlanCell", forIndexPath: indexPath) as! InviteAddPlanCell
            cell.addButton.addTarget(self, action: #selector(InvitePlanVC.addPlan(_:)), forControlEvents: .TouchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
            cell.clearAllViews()
            let index = indexPath.row - 1
            cell.plan = plans[index]
            let workoutId = workouts[index].id
            cell.asyncIdentifer = workoutId

            if let dateString = selectedDate.toString() {
                let cacheId = workoutId + dateString
                if let _invite = InvitationCache.sharedInstance.cache[cacheId] {
                    cell.userInteractionEnabled = false
                    cell.borderView.alpha = 0.5
                    cell.invite = _invite
                    cell.showTimeView()
                    cell.showLocView()
                    cell.showStatusView()
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                    cell.layoutSubviews()
                    Log.info("senTo = \(_invite.sentTo)")
                    if _invite.sentTo != nil{
                        if _invite.sentTo != "public" && _invite.sentTo != "friends" {
                            User.getUserArrayFromIdList([_invite.sentTo], successHandler: { (user: [User]) in
                                guard let screenName = user[0].screenName else {return}
                                cell.statusLabel.text = "Invitation sent to \(screenName)"
                            })
                        } else {
                            cell.statusLabel.text = "Invitation sent to \(_invite.sentTo)"
                        }
                    }
                } else {
                    Invite.getWorkoutInviteByScheduledWorkoutIdAndDate(workoutId, date: selectedDate, completion: { (error: NSError?, invite: Invite?) in
                        if let _invite = invite where error == nil {
                            let asyncId = workoutId
                            let curCell = cell
                            if curCell.asyncIdentifer == asyncId {
                                //remove shadow
                                InvitationCache.sharedInstance.cache[cacheId] = _invite
                                cell.userInteractionEnabled = false
                                cell.borderView.alpha = 0.5
                                tableView.beginUpdates()
                                cell.invite = _invite
                                cell.showTimeView()
                                cell.showLocView()
                                cell.showStatusView()
                                cell.setNeedsLayout()
                                cell.layoutIfNeeded()
                                cell.layoutSubviews()
                                tableView.endUpdates()
                                Log.info("senTo = \(_invite.sentTo)")
                                if _invite.sentTo != nil{
                                    if _invite.sentTo != "public" && _invite.sentTo != "friends" {
                                        User.getUserArrayFromIdList([_invite.sentTo], successHandler: { (user: [User]) in
                                            guard let screenName = user[0].screenName else {return}
                                            cell.statusLabel.text = "Invitation sent to \(screenName)"
                                        })
                                    } else {
                                        cell.statusLabel.text = "Invitation sent to \(_invite.sentTo)"
                                    }
                                }
                                
                            }
                        }
                        
                    })
                }
                
                
            }


            
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            cell.dateLabel.text = dateFormatter.stringFromDate(selectedDate)

            //disable the cell

            
            //show these views if the invitation is sent and not selectable


            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        nextButton.enabled = true
        nextButton.backgroundColor = ColorScheme.p1Tint
        Log.info("didSelectRowAtIndexPath prev selected = \(selected) plans count = \(plans.count)")
        // deselect previous selected items
        if selected != -1 && selected <= plans.count {
            let selectedIndexPath = NSIndexPath(forRow: selected, inSection: 0)
            let cellToDeselect = tableView.cellForRowAtIndexPath(selectedIndexPath)
            print(cellToDeselect)
            if let _cellToDeselect = cellToDeselect as? InviteNoPlanCell {
                _cellToDeselect.borderView.layer.borderWidth = 0.0
                
            }
            if let _cellToDeselect = cellToDeselect as? WorkoutCell {
                _cellToDeselect.borderView.layer.borderWidth = 0.0
                
            }
        }

        
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
        Log.info("willDisplayCell fired")
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
