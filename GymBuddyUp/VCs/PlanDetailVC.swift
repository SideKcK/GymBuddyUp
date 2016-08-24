//
//  PlanDetailVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/17/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanDetailVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var planLabel: UILabel!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var timeLocView: UIStackView!
    @IBOutlet weak var gymButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelInviteButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var workoutButton: UIButton!
    
    var selectedDate: NSDate!
    var workout: ScheduledWorkout!
    var plan: Plan!
    var sendTo = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = weekMonthDateString(selectedDate)
        setTableView()
        setViews(false)
        setupVisual()
        
        timeLabel.text = timeString(NSDate())
        self.title = weekMonthDateString(NSDate())
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupVisual() {
        workoutButton.makeActionButton()
        findButton.makeBorderButton(ColorScheme.p1Tint)
        moreButton.tintColor = ColorScheme.g2Text
        gymButton.setTitleColor(ColorScheme.p1Tint, forState: .Normal)
        statusView.makeBorderButton(ColorScheme.g2Text)
        
        findButton.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
        planLabel.font = FontScheme.H1
        gymButton.titleLabel?.font = FontScheme.T2
    }
    
    func setTableView() {
        tableView.registerNib(UINib(nibName: "ExerciseNumberedCell", bundle: nil), forCellReuseIdentifier: "ExerciseNumberedCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
    }

    func setViews(invited: Bool) {
        timeLocView.hidden = !invited
        statusView.hidden = !invited
        statusViewHeight.priority = invited ? 250:999
        findButton.hidden = invited
        setStatusBar()
        
    }

    func setStatusBar() {
        if sendTo == 1 {
            statusLabel.text = "Searching SideKcK in Buddy List"
        } else if sendTo == 2 {
            statusLabel.text = "Searching SideKcK in Public"
        } else {
            statusLabel.text = " invited"
        }
    }

    @IBAction func onMoreButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.customize()
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        let repeating = workout.recur == 7
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            //delete
            if repeating {
                let deleteController = UIAlertController(title: nil, message: "This is a repeating plan.", preferredStyle: .ActionSheet)
                deleteController.customize()
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    // ...
                }
                deleteController.addAction(cancelAction)
                let DeleteAllAction = UIAlertAction(title: "Delete All Future Plans", style: .Destructive) { (action) in
                    ScheduledWorkout.deleteScheduledWorkout(self.workout.id, completion: { (error) in
                        if error == nil {
                            print("deleted all future plans")
                        }else {
                            print(error)
                        }
                    })
                }
                deleteController.addAction(DeleteAllAction)
                let DeleteThisAction = UIAlertAction(title: "Delete This Plan Only", style: .Destructive) { (action) in
                    ScheduledWorkout.skipScheduledWorkoutForDate(self.workout.id, date: self.selectedDate, completion: { (error) in
                        if error == nil {
                            print("delete this plan only")
                            self.performSegueWithIdentifier("unwindToPlanMainVC", sender: "delete")
                        }else {
                            print(error)
                        }
                    })
                }
                deleteController.addAction(DeleteThisAction)
                self.presentViewController(deleteController, animated: true, completion: nil)
            }else {
                ScheduledWorkout.deleteScheduledWorkout(self.workout.id, completion: { (error) in
                    if error == nil {
                        print("deleted plan")
                        self.performSegueWithIdentifier("unwindToPlanMainVC", sender: "delete")
                    }else {
                        print(error)
                    }
                })
            }
        }
        alertController.addAction(DeleteAction)
        
        if !repeating {
            let RepeatAction = UIAlertAction(title: "Repeat Weekly", style: .Default) { (action) in
                //set plan as repeat
                ScheduledWorkout.repeatScheduledWorkout(self.workout.id, recur: 7, completion: { (error) in
                    if error == nil {
                        print("repeat plan")
                        self.performSegueWithIdentifier("unwindToPlanMainVC", sender: "repeat")
                    }else {
                        print(error)
                    }
                })
            }
            alertController.addAction(RepeatAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onCancelInviteButton(sender: AnyObject) {
        print("cancel invite")
        var message = ""
        if sendTo == 1 || sendTo == 2{
            message = "Cancel broadcasting?"
        }else {
            message = "Cancel invitation?"
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        alertController.customize()
        let cancelAction = UIAlertAction(title: "No, Keep it", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Yes", style: .Destructive) { (action) in
            //cancel invitation
            self.setViews(false)
        }
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "startWorkoutSegue" {
            let desNC = segue.destinationViewController as! UINavigationController
            let desVC = desNC.topViewController as! TrackMainVC
            desVC.trackedPlan = TrackedPlan(plan: plan)
        }
        
        
        if segue.identifier ==  "toExerciseDetailSegue" {
            if let desVC = segue.destinationViewController as? PlanExerciseVC {
                if let exercises = plan.exercises {
                    desVC.exercise = exercises[sender as! Int]
                }
            }
        }
        if let desVC = segue.destinationViewController as? PlanMainVC {
            if let send = sender as? String {
                if send == "delete" || send == "repeat"{
                    desVC.reloadPlans(desVC.selectedDate)
                }
            }
        }
        if let desVC = segue.destinationViewController as? GymMapVC {
            desVC.gym = Gym()
            desVC.userLocation = CLLocation(latitude: 30.562, longitude: -96.313)
        }

    }
 

}

extension PlanDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exercises = plan.exercises {
            return exercises.count
        }else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseNumberedCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        if let exercises = plan.exercises {
            cell.exercise = exercises[indexPath.row]
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}