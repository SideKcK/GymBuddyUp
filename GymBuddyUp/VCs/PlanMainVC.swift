//
//  PlanMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CVCalendar
import SwiftDate
import KRProgressHUD

class PlanMainVC: UIViewController {
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var monthButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPlanButton: UIButton!
    @IBOutlet weak var addPlanView: UIView!
    @IBOutlet weak var todayButton: UIBarButtonItem!
    
    var dots = [NSDate]()
    var workouts = [NSDate: [ScheduledWorkout]]()
    var plans = [NSDate: [Plan]]()
    var dayPlans = [Plan]()
    var selectedDate: NSDate!
    
    let insetColor = ColorScheme.g3Text
    let tintColor = ColorScheme.p1Tint
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisual()
        setCalendar()
        setTableView()
        addPlanButton.addShadow()
        getPlansThisWeek(selectedDate)
        todayButton.tintColor = ColorScheme.s1Tint
    }
    
    func setupVisual() {
        menuView.backgroundColor = ColorScheme.s1Tint
        calendarView.backgroundColor = ColorScheme.s1Tint
        
        addPlanView.backgroundColor = ColorScheme.s3Bg
        tableView.backgroundColor = ColorScheme.s3Bg
    }
    
    func setTableView() {
        tableView.registerNib(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func setCalendar() {
        calendarView.calendarAppearanceDelegate = self
        menuView.delegate = self
        calendarView.delegate = self
        monthButton.title = "< " + CVDate(date: NSDate()).monthDescription
        selectedDate = NSDate().startOf(.Day)
        getCalendarWorkouts(selectedDate)
        
    }
    
    func reloadPlans(date: NSDate) {
        KRProgressHUD.show()
        
        ScheduledWorkout.getScheduledWorkoutsForDate(date) { (workouts) in
            self.workouts[date] = workouts
            if let planIds = Plan.planIDsWithArray(workouts) {
                Library.getPlansById(planIds, completion: { (plans, error) in
                    if error == nil {
                        self.plans[date] = plans
                        // reload tableview with plans
                        if date == self.selectedDate {
                            self.tableView.reloadData()
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
        
        let firstDayOfWeek = date.startOf(.WeekOfYear)
        let fetchPlanTaskGroup = dispatch_group_create()

        
        for i in (0..<7) {

            let day = firstDayOfWeek + i.days
            dispatch_group_enter(fetchPlanTaskGroup)
            
            ScheduledWorkout.getScheduledWorkoutsForDate(day, complete: { (workoutsOnDay) in
                self.workouts[day] = workoutsOnDay

                if workoutsOnDay.count == 0 {
                    self.plans[day] = []
                    dispatch_group_leave(fetchPlanTaskGroup)
                }
                    
                else {
                    let planIds = Plan.planIDsWithArray(workoutsOnDay)
                    Library.getPlansById(planIds!, completion: { (plans, error) in
                        if error == nil {
                            self.plans[day] = plans
                        }
                        else {
                            print("Error getting plans for this week", error)
                        }
                        
                        dispatch_group_leave(fetchPlanTaskGroup)
                    })
                }
            })
        }
        
        dispatch_group_notify(fetchPlanTaskGroup, dispatch_get_main_queue(), {
            //reload tableview with plans
            self.tableView.reloadData()
            KRProgressHUD.dismiss()
        })
    }
    
    
    
//        }
//        KRProgressHUD.show()
//        let sWeek = date.startOf(.WeekOfYear)
//        let eWeek = date.endOf(.WeekOfYear)
//        print(sWeek.toString())
//        print(eWeek.toString())
//        ScheduledWorkout.getScheduledWorkoutsForTimespan(sWeek, endDate: eWeek) { (workouts, error) in
//            if let workouts = workouts {
//                for (workoutdate, workout) in workouts {
//                    self.workouts[workoutdate] = workout
//                    
//                }
//                let myGroup = dispatch_group_create()
//                for (date, dayworkouts) in workouts {
//                    dispatch_group_enter(myGroup)
//                    if let planIds = Plan.planIDsWithArray(dayworkouts) {
//                        Library.getPlansById(planIds, completion: { (plans, error) in
//                            if error == nil {
//                                self.plans[date] = plans
//                                //get plan invitation status
//                                
//                            }else {
//                                print("Network Error AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", error)
//                                KRProgressHUD.showError(message: "Network Error")
//                            }
//                            dispatch_group_leave(myGroup)
//                        })
//                    }
//                }
//                
//                dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
//                    
//                    //reload tableview with plans
//                    self.tableView.reloadData()
//                    KRProgressHUD.dismiss()
//                })
//                
//            }else {
//                print("Network Error AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", error)
//                KRProgressHUD.showError(message: "Network Error")
//            }
//            
//        }
//        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
//            if KRProgressHUD.isVisible {
//                
//                KRProgressHUD.showError(message: "Network Error")
//            }
//        })
//    }
    
    func getCalendarWorkouts (date: NSDate) {
        let sMonth = (1.weeks).agoFromDate(date.startOf(.Month))
        let eMonth = (1.weeks).fromDate(date.endOf(.Month))
        ScheduledWorkout.getScheduledWorkoutsForTimespan(sMonth, endDate: eMonth) { (workouts, error) in
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
        self.reloadPlans(self.selectedDate)
    }
    
    func onGymButton (sender: UIButton) {
        self.performSegueWithIdentifier("toGymMapSegue", sender: self)
    }
    
    func onProfileButton (sender: UIButton) {
        self.performSegueWithIdentifier("toProfileSegue", sender: self)
    }
    
    @IBAction func onMonthButton(sender: AnyObject) {
//        calendarView.changeMode(.MonthView)
//        UIView.animateWithDuration(0.3, animations: {
//            self.tableView.alpha = 0
//            self.addPlanView.alpha = 0
//        })
    }
    @IBAction func onTodayButton(sender: AnyObject) {
        print("on today button")
        calendarView.changeMode(.WeekView) {
            print("changed mode")
            self.calendarView.toggleCurrentDayView()
        }
        //calendarView.changeMode(.WeekView)
        //add selection circle to todays dayview
        
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
    
    func onMoreButton(sender: UIButton!) {
        guard let workout = workouts[selectedDate]?[sender.tag] else {
            print("on more button error")
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.customize()
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let inviteAction = UIAlertAction(title: "Find Your SideKcK", style: .Default) { (action) in
            self.performSegueWithIdentifier("toInvitationSegue", sender: workout)
        }
        alertController.addAction(inviteAction)
        let repeating = workout.recur == 7
        let RepeatAction = UIAlertAction(title: "Repeat Weekly", style: .Default) { (action) in
            //set plan as repeat
            ScheduledWorkout.repeatScheduledWorkout(workout.id, recur: 7, completion: { (error) in
                if error == nil {
                    print("repeat weekly")
                    self.reloadPlans(self.selectedDate)
                }else {
                    print(error)
                }
                
            })
        }
        if !repeating {
            alertController.addAction(RepeatAction)
        }
        
        
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
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /* Yi Huang: should return in each branch to terminate extra comparisons*/
        if let desVC = segue.destinationViewController as? PlanDetailVC {
            desVC.selectedDate = selectedDate
            if let row = sender as? Int {
                desVC.plan =  plans[selectedDate]![row]
                desVC.workout = workouts[selectedDate]![row]
            }
        }
        if segue.identifier == "toPlanLibrarySegue" {
            if let desVC = segue.destinationViewController as? PlanLibNavVC {
                desVC.selectedDate = selectedDate
            }
        }
        if let desVC = segue.destinationViewController as? GymMapVC {
            desVC.gym = Gym()
            desVC.userLocation = CLLocation(latitude: 30.562, longitude: -96.313)
        }
        if let desVC = segue.destinationViewController as? MeMainVC {
            //for testing
            //desVC.user = User()
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
        if dayView.date.month != selectedDate.month {
            print("select day view")
            calendarView.changeMode(.WeekView)
        }

        selectedDate = dayView.date.convertedDate()?.startOf(.Day)
        todayButton.tintColor = selectedDate != NSDate().startOf(.Day) ? ColorScheme.g4Text : ColorScheme.s1Tint
        
        if plans[selectedDate] == nil {
            getPlansThisWeek(selectedDate)
        }else {
            tableView.reloadData()
        }
        
        UIView.animateWithDuration(0.3, animations: {
            self.tableView.alpha = 1
            self.addPlanView.alpha = 1
        })
    }
    
    func presentedDateUpdated(date: CVDate) {
        print("presented date updated \(date.commonDescription)")
        
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
        
        let color = ColorScheme.g4Text
        
        return [color] // return 1 dot
        
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 5
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return ColorScheme.g4Text
    }
    
    
    
}

extension PlanMainVC: CVCalendarViewAppearanceDelegate {
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return ColorScheme.g4Text
    }
    
    func dayLabelWeekdayOutTextColor() -> UIColor {
        return ColorScheme.g4Text
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return ColorScheme.s1Tint
    }
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return ColorScheme.s1Tint
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return ColorScheme.g4Text
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return ColorScheme.g4Text
    }
    
    func dotMarkerColor() -> UIColor {
        return ColorScheme.g4Text
    }
    
}

extension PlanMainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let plans = plans[selectedDate] {
            return plans.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
        guard let dayPlans = plans[selectedDate], dayWorkouts = workouts[selectedDate] else {
            return cell
        }
        let index = indexPath.row
        cell.clearAllViews()
        cell.plan = dayPlans[index]
        let workoutId = dayWorkouts[index].id
        
        cell.asyncIdentifer = workoutId
        
        // async fetch userInfo
        Invite.getWorkoutInviteByScheduledWorkoutIdAndDate(workoutId, date: selectedDate, completion: { (error: NSError?, invite: Invite?) in
            if let _invite = invite where error == nil {
                let asyncId = workoutId
                let curCell = cell
                if curCell.asyncIdentifer == asyncId {
                    //remove shadow
                    tableView.beginUpdates()
                    cell.invite = _invite
                    cell.borderView.clipsToBounds = true
//                    cell.showDateView()
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

        
        cell.showMoreButton()
        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(PlanMainVC.onMoreButton(_:)), forControlEvents: .TouchUpInside)
        //add gym segue
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toPlanDetailSegue", sender: indexPath.row)
    }
}
