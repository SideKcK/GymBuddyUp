//
//  PlanMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CVCalendar
import KRProgressHUD

class PlanMainVC: UIViewController {
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var monthButton: UIBarButtonItem!
    
    @IBOutlet weak var planLabel: UILabel!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var timeLocView: UIStackView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var workoutButton: UIButton!
    
    var dots = [NSDate]()
    var workouts = [NSDate: [ScheduledWorkout]]()
    var plans = [NSDate: [Plan]]()
    var selectedDate: NSDate!
    var sendTo = 2
    
    let insetColor = ColorScheme.sharedInstance.greyText
    let tintColor = ColorScheme.sharedInstance.buttonTint
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendar()
        self.emptyView.hidden = true
        self.planView.hidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        getPlansThisWeek(selectedDate)
    }
    
    func setViews(hasPlan: Bool, invited: Bool) {
        workoutButton.hidden = !hasPlan
        timeLocView.hidden = !invited
        emptyView.hidden = hasPlan
        planView.hidden = !hasPlan
        statusView.hidden = !invited
        statusViewHeight.priority = invited ? 250:999
        findButton.hidden = invited
        setStatusBar()
        
    }
    
    func setCalendar() {
        calendarView.backgroundColor = ColorScheme.sharedInstance.calBg
        menuView.backgroundColor = ColorScheme.sharedInstance.calBg
        calendarView.calendarAppearanceDelegate = self
        menuView.delegate = self
        calendarView.delegate = self
        monthButton.title = "< "+CVDate(date: NSDate()).monthDescription
        selectedDate = NSDate().startOf(.Day)
        getCalendarWorkouts(selectedDate)
        
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
    func reloadPlans(date: NSDate) {
        KRProgressHUD.show()

        ScheduledWorkout.getScheduledWorkoutsForDate(date) { (workouts) in
            self.workouts[date] = workouts
            if let planIds = Plan.planIDsWithArray(workouts) {
                Library.getPlansById(planIds, completion: { (plans, error) in
                    if let dayplans = plans {
                        self.plans[date] = dayplans
                        if dayplans.count == 0 {
                            self.setViews(false, invited: false)
                        }else {
                        self.tableView.reloadData()
                        self.setViews(true, invited: false)
                        }
                    }else {
                        print(error)
                        KRProgressHUD.showError()
                    }
                    KRProgressHUD.dismiss()
                    self.dots.removeAll()
                    self.getCalendarWorkouts(date)

                })
            }
        }
    }
    
    func getPlansThisWeek(date: NSDate) {
        KRProgressHUD.show()
        let sWeek = date.startOf(.WeekOfYear)
        let eWeek = date.endOf(.WeekOfYear)
        print(sWeek.toString())
        print(eWeek.toString())
        ScheduledWorkout.getScheduledWorkoutsInRange(sWeek, endDate: eWeek) { (workouts, error) in
            if let workouts = workouts {
                for (workoutdate, workout) in workouts {
                    self.workouts[workoutdate] = workout
                    
                }
                let myGroup = dispatch_group_create()
                for (date, dayworkouts) in workouts {
                    dispatch_group_enter(myGroup)
                    if let planIds = Plan.planIDsWithArray(dayworkouts) {
                        Library.getPlansById(planIds, completion: { (plans, error) in
                            if let dayplans = plans {
                                self.plans[date] = dayplans
                                //get plan invitation status
                                
                            }else {
                                print(error)
                            }
                            dispatch_group_leave(myGroup)
                        })
                    }
                }
                
                dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
                    print("getPlansThisWeek: Finished all requests.")
                    
                    if let plans = self.plans[self.selectedDate] {
                        if plans.count == 0 {
                            self.setViews(false, invited: false)
                        }else {
                            self.planLabel.text = plans[0].name
                            self.tableView.reloadData()
                            self.setViews(true, invited: false)
                        }

                    }
                    KRProgressHUD.dismiss()
                })
                
            }else {
                print(error)
            }
            
        }
    }
    
    func getCalendarWorkouts (date: NSDate) {
        let sMonth = (1.weeks).agoFromDate(date.startOf(.Month))
        let eMonth = (1.weeks).fromDate(date.endOf(.Month))
        ScheduledWorkout.getScheduledWorkoutsInRange(sMonth, endDate: eMonth) { (workouts, error) in
            if let workouts = workouts {
                for (date, dayworkouts) in workouts {
                    if dayworkouts.count != 0 {
                        self.dots.append(date)
                    }
                }
                self.calendarView?.contentController.refreshPresentedMonth()
                
            }else {
                print(error)
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToPlanMainVC(segue: UIStoryboardSegue) {
        
    }
    @IBAction func onMonthButton(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
        UIView.animateWithDuration(0.3, animations: {
            self.emptyView.alpha = 0
            self.planView.alpha = 0
        })
    }
    @IBAction func onTodayButton(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
        calendarView.toggleCurrentDayView()
        //add selection circle to todays dayview
        
    }
    
    @IBAction func onMoreButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        let workout = self.workouts[selectedDate]![0]
        let repeating = workout.recur == 7
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            //delete
            if repeating {
                let deleteController = UIAlertController(title: nil, message: "This is a repeating plan.", preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    // ...
                }
                deleteController.addAction(cancelAction)
                let DeleteAllAction = UIAlertAction(title: "Delete All Future Plans", style: .Destructive) { (action) in
                    ScheduledWorkout.deleteScheduledWorkout(workout.id, completion: { (error) in
                        if error == nil {
                        print("deleted all future plans")
                        self.reloadPlans(self.selectedDate)
                        }else {
                            print(error)
                        }
                    })
                }
                deleteController.addAction(DeleteAllAction)
                let DeleteThisAction = UIAlertAction(title: "Delete This Plan Only", style: .Destructive) { (action) in
                    ScheduledWorkout.skipScheduledWorkoutForDate(workout.id, date: self.selectedDate, completion: { (error) in
                        if error == nil {
                        print("delete this plan only")
                        self.reloadPlans(self.selectedDate)
                        }else {
                            print(error)
                        }
                    })
                }
                deleteController.addAction(DeleteThisAction)
                self.presentViewController(deleteController, animated: true, completion: nil)
            }else {
                ScheduledWorkout.deleteScheduledWorkout(workout.id, completion: { (error) in
                    if error == nil {
                    print("deleted plan")
                    self.reloadPlans(self.selectedDate)
                    }else {
                        print(error)
                    }
                })
            }
        }
        alertController.addAction(DeleteAction)
        
        let ReplaceAction = UIAlertAction(title: "Replace", style: .Default) { (action) in
            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        }
        alertController.addAction(ReplaceAction)
        
        let RepeatAction = UIAlertAction(title: "Repeat Weekly", style: .Default) { (action) in
            //set plan as repeat
            
        }
        if !repeating {
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
        let cancelAction = UIAlertAction(title: "No, Keep it", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Yes", style: .Destructive) { (action) in
            //cancel invitation
            self.setViews(true, invited: false)
        }
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onNewPlanButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        //        let alertController = UIAlertController(title: nil, message: "New Plan", preferredStyle: .ActionSheet)
        //
        //        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        //            // ...
        //        }
        //        alertController.addAction(cancelAction)
        //
        //        let BuildAction = UIAlertAction(title: "Build your own", style: .Default) { (action) in
        //            self.performSegueWithIdentifier("toBuildPlanSegue", sender: self)
        //        }
        //        alertController.addAction(BuildAction)
        //
        //        let LibAction = UIAlertAction(title: "SideKck training library", style: .Default) { (action) in
        //            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        //        }
        //        alertController.addAction(LibAction)
        //
        //        self.presentViewController(alertController, animated: true) {
        //            // ...
        //        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier ==  "toExerciseDetailSegue" {
            if let desVC = segue.destinationViewController as? PlanExerciseVC {
                if let plans = plans[selectedDate], exercises = plans[0].exercises {
                    desVC.exercise = exercises[sender as! Int]
                }
            }
        }
        if segue.identifier == "toPlanLibrarySegue" {
            if let desVC = segue.destinationViewController as? PlanLibNavVC {
                desVC.selectedDate = selectedDate
            }
        }
        
    }
    
    
}

extension PlanMainVC: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    //    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
    //        let frame = dayView.frame
    //        let arcCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
    //        let startAngle = CGFloat(0)
    //        let endAngle = CGFloat(M_PI * 2.0)
    //        let clockwise = true
    //
    //        let path = UIBezierPath(arcCenter: arcCenter, radius: (min(frame.height, frame.width) - 10) / 2,
    //                                startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
    //
    //
    //        return UIView()
    //
    //    }

    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedDate = dayView.date.convertedDate()?.startOf(.Day)
        if plans[selectedDate] == nil {
            getPlansThisWeek(selectedDate)
        }else if plans[selectedDate]?.count != 0{
            self.planLabel.text = plans[selectedDate]![0].name
            tableView.reloadData()
            setViews(true, invited: false)
        }else {
            setViews(false, invited: false)
        }
        calendarView.changeMode(.WeekView)
        UIView.animateWithDuration(0.3, animations: {
            self.emptyView.alpha = 1
            self.planView.alpha = 1
        })
    }
    
    func presentedDateUpdated(date: CVDate) {
        if monthButton.title != date.monthDescription {
            getCalendarWorkouts(date.convertedDate()!)
            //monthButton.alpha = 0
            UIView.animateWithDuration(0.3, animations: {
                self.monthButton.title = "< "+date.monthDescription
            })
        }
    }
    
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let date = dayView.date.convertedDate()
        if self.dots.contains(date!) {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        let color = ColorScheme.sharedInstance.calText
        
        return [color] // return 1 dot
        
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 5
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    
    
}

extension PlanMainVC: CVCalendarViewAppearanceDelegate {
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    func dayLabelWeekdayOutTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calTextDark
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calBg
    }
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calBg
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    func dotMarkerColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
}

extension PlanMainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let plans = plans[selectedDate],
            exercises = plans[0].exercises {
            return exercises.count
        }else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        if let plans = plans[selectedDate], exercises = plans[0].exercises {
            cell.exercise = exercises[indexPath.row]
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}

