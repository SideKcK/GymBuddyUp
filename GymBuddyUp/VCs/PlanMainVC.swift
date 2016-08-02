//
//  PlanMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CVCalendar

class PlanMainVC: UIViewController {
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var monthButton: UIBarButtonItem!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var timeLocView: UIStackView!
    
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var workoutButton: UIButton!
    
    var plan: Plan?
    var selectedDay: DayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendar()
        reset()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        Plan.getTodayPlan { (plan:Plan!, error: NSError!) in
            if plan != nil {
                self.plan = plan
                self.tableView.reloadData()
                self.planView.hidden = false
                self.workoutButton.hidden = false
            }else {
                self.emptyView.hidden = false
            }
        }
        
    }
    
    func reset() {
        workoutButton.hidden = true
        timeLocView.hidden = true
        planView.hidden = true
        emptyView.hidden = true
    }
    
    func setCalendar() {
        calendarView.backgroundColor = ColorScheme.sharedInstance.calBg
        menuView.backgroundColor = ColorScheme.sharedInstance.calBg
        calendarView.calendarAppearanceDelegate = self
        menuView.delegate = self
        calendarView.delegate = self
        monthButton.title = "< "+CVDate(date: NSDate()).monthDescription
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
            
            self.planView.alpha = 0
            self.emptyView.alpha = 0
        })
    }
    @IBAction func onTodayButton(sender: AnyObject) {
        calendarView.toggleCurrentDayView()
        calendarView.changeMode(.WeekView)
        
    }
    
    @IBAction func onMoreButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            Plan.deleteTodayPlan({ (error) in
                print("deleting plan: \(error)")
                self.planView.hidden = true
            })
        }
        alertController.addAction(DeleteAction)
        
        let ReplaceAction = UIAlertAction(title: "Replace", style: .Default) { (action) in
            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        }
        alertController.addAction(ReplaceAction)
        
        let RepeatAction = UIAlertAction(title: "Repeat Weekly", style: .Default) { (action) in
            //set plan as repeat
            Plan.repeatTodayPlan({ (error) in
                print("set repeat: \(error)")
            })
        }
        alertController.addAction(RepeatAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
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
                if let plan = plan, exercises = plan.exercises {
                    desVC.exercise = exercises[sender as! Int]
                }
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
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedDay = dayView
        Plan.getPlan(User.currentUser, date: selectedDay.date.convertedDate()) { (plan, error) in
            if error == nil {
                self.plan = plan
                self.tableView.reloadData()
            }
        }
        calendarView.changeMode(.WeekView)
        UIView.animateWithDuration(0.3, animations: {
            
            self.planView.alpha = 1
            self.emptyView.alpha = 1
        })
    }
    
    func presentedDateUpdated(date: CVDate) {
        if monthButton.title != date.monthDescription {
            //monthButton.alpha = 0
            UIView.animateWithDuration(0.3, animations: {
                self.monthButton.title = "< "+date.monthDescription
            })
        }
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date.day
        if day == 1 {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        let color = ColorScheme.sharedInstance.calText
        
        return [color] // return 1 dot
        
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
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
    
    func dotMarkerOffset() -> CGFloat {
        return 0
    }
    
}

extension PlanMainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let plan = plan, exercises = plan.exercises {
            return exercises.count
        }else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        if let plan = plan, exercises = plan.exercises {
            cell.exercise = exercises[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}

