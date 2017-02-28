//
//  PlanDetailVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/17/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import KRProgressHUD

@objc protocol showCheckInButtonDelegate {
    optional func showCheckInButton()
}

@objc protocol showTrackingInfoDelegate {
    optional func showTrackingTable()
}
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
    
    @IBOutlet weak var checkinButton: UIButton!
    
    @IBOutlet weak var checkinLabel: UILabel!
    @IBOutlet weak var checkinImage: UIImageView!
    
    var selectedDate: NSDate!
    var workout: ScheduledWorkout!
    var plan: Plan!
    var trackedPlan: TrackedPlan?
    var sendTo = ""
    var startTime: NSDate!
    var gym: Gym?
    var isInvite = false
    var invite: Invite?
    var delegate: reloadPlanInfoDelegate?
    override func viewDidLoad() {
        Log.info("PlanDetailVC fired")
        super.viewDidLoad()
        checkinButton.hidden = true
        checkinImage.hidden = true
        checkinLabel.hidden = true
        self.title = weekMonthDateString(selectedDate)
        print("Inside viewDidLoad")
        if let _invite = workout.invite{
            isInvite = true
            if let _gym = _invite.gym{
                print("Gym is not nil")
                self.gym = _gym
            }
            self.timeLabel.text = timeString(_invite.workoutTime)
        }
        if invite != nil {
            if invite!.id != "-1"{
                sendTo = invite!.sentTo
                print("sendTo : " + sendTo)
            }
        }
        let currentDate = NSDate()
        let getTrackedItemGroup = dispatch_group_create()
        if (selectedDate < currentDate || dateToString(selectedDate) == dateToString(currentDate)) {
            dispatch_group_enter(getTrackedItemGroup)
            Tracking.getTrackedPlanById(String(workout.id) + ":" + dateToString(selectedDate)){(result, error) in
                if(result != nil){
                    self.trackedPlan = result
                    
                    self.timeLabel.text = timeString((self.trackedPlan?.startDate)!)
                    
                    if(self.trackedPlan?.gym != nil){
                        
                        self.gymButton.titleLabel?.text = self.trackedPlan?.gym?.name
                        self.gymButton.setTitle(self.trackedPlan?.gym?.name, forState: UIControlState.Normal)
                        self.gymButton.enabled = false
                    }
                }else{
                    if self.gym != nil {
                        self.gymButton.titleLabel?.text = self.gym?.name
                        self.gymButton.setTitle(self.gym?.name, forState: UIControlState.Normal)
                        self.gymButton.enabled = false
                        //self.gymButton.addTarget(self, action: #selector(self.onGymButton), forControlEvents: .TouchUpInside)
                    }else{
                        self.gymButton.hidden = true
                    }
                    print("start date" + String(dateToInt(self.workout.startDate)))
                    
                }
                dispatch_group_leave(getTrackedItemGroup)
            }
            dispatch_group_notify(getTrackedItemGroup, dispatch_get_main_queue()) {
                self.setTableView()
                print("self.isInvite 1:" + String(self.isInvite))
                self.setViews(self.isInvite)
                self.setupVisual()
                
                self.title = weekMonthDateString(self.selectedDate)
                self.planLabel.text = self.plan.name
                
            }
            
        } else {
            if gym != nil {
                self.gymButton.titleLabel?.text = self.gym?.name
                self.gymButton.setTitle(self.gym?.name, forState: UIControlState.Normal)
                self.gymButton.enabled = false
                //gymButton.addTarget(self, action: #selector(onGymButton), forControlEvents: .TouchUpInside)
            }else{
                self.gymButton.hidden = true
            }
            setTableView()
            print("self.isInvite 2:" + String(isInvite))
            setViews(isInvite)
            setupVisual()
            self.title = weekMonthDateString(self.selectedDate)
        }
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.Bordered, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton
        // Do any additional setup after loading the view.
    }
    func back(sender: UIBarButtonItem) {
        self.delegate?.reloadPlanInfo!()
        self.navigationController?.popViewControllerAnimated(true)
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
    func setupVisual() {
        workoutButton.makeActionButton()
        checkinButton.makeActionButton()
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
        self.planLabel.text = self.plan.name
        timeLocView.hidden = !invited
        statusView.hidden = !invited
        statusViewHeight.priority = invited ? 250:999
        findButton.hidden = invited
        let isEmpty = checkIsEmptyExercise()
        let isTracked = checkIsTracked()

        var allowStart = true
        var allowFind = false
        let currentDate = NSDate()
        if(dateToString(selectedDate) != dateToString(currentDate)){
            allowStart = false
        }
        if(dateToString(selectedDate) == dateToString(currentDate) || selectedDate > currentDate){
            allowFind = true
        }
        if(isEmpty){
            tableView.hidden = isEmpty
            workoutButton.hidden = isEmpty
            if(allowStart){
                checkinButton.hidden = isTracked
            }else{
                checkinButton.hidden = true
            }
            checkinImage.hidden = !isTracked
            checkinLabel.hidden = !isTracked
        }else{
            tableView.hidden = isEmpty
            if(allowStart){
                workoutButton.hidden = isTracked
                checkinButton.hidden = !isEmpty
                checkinImage.hidden = !isEmpty
                checkinLabel.hidden = !isEmpty
            }else{
                workoutButton.hidden = true
                if(!allowFind){
                    findButton.hidden = true
                }else{
                    findButton.hidden = invited
                }
                checkinButton.hidden = true
                checkinImage.hidden = true
                checkinLabel.hidden = true
            }
        }
        if(isTracked){
            timeLocView.hidden = false
            findButton.hidden = true
        }
        print("allowFind" + String(allowFind) )
        print("allowStart" + String(allowStart) )
        print("allowFind" + String(allowFind) )
        setStatusBar()
    }
    
    func setStatusBar() {
        /*if sendTo == "friends" {
            statusLabel.text = "Searching a gymbuddy in Buddy List"
        } else if sendTo == "public" {
            statusLabel.text = "Searching a gymbuddy in Public"
        } else if sendTo != ""{
            User.getUserArrayFromIdList([sendTo], successHandler: { (user: [User]) in
                guard let screenName = user[0].screenName else {return}
                self.statusLabel.text =  "Invitation sent to \(screenName)"
            })
        }*/
        if let _invite = invite{
            if _invite.id != "-1" {
        if _invite.isAvailable == false {
            if _invite.inviterId == User.currentUser?.userId {
                if _invite.inviteeId != nil {
                    User.getUserArrayFromIdList([_invite.inviteeId!], successHandler: { (user: [User]) in
                        guard let screenName = user[0].screenName else {return}
                        self.statusLabel.text = "Workout with \(screenName)"
                    })
                }else {
                    self.statusLabel.text = "Workout with unnamed user"
                }
            }else {
                if _invite.inviterId != nil {
                    User.getUserArrayFromIdList([_invite.inviterId!], successHandler: { (user: [User]) in
                        guard let screenName = user[0].screenName else {return}
                        self.statusLabel.text = "Workout with \(screenName)"
                    })
                }else {
                    self.statusLabel.text = "Workout with unnamed user"
                }
                
            }
        }else if _invite.sentTo != nil {
            if _invite.inviterId != User.currentUser?.userId {
                if let user = UserCache.sharedInstance.cache[_invite.inviterId] {
                    if let screenName = user.screenName {
                        self.statusLabel.text = "Workout with \(screenName)"
                    } else {
                        self.statusLabel.text = "Workout with unnamed user"
                    }
                    
                } else {
                    User.getUserArrayFromIdList([_invite.inviterId], successHandler: { (users: [User]) in
                        if users.count > 0 {
                            UserCache.sharedInstance.cache[_invite.inviterId] = users[0]
                            guard let screenName = users[0].screenName else {return}
                            self.statusLabel.text = "Workout with \(screenName)"
                        }
                    })
                }
            } else {
                if let recipientId = _invite.sentTo {
                    if _invite.sentTo != "public" && _invite.sentTo != "friends" {
                        if let user = UserCache.sharedInstance.cache[recipientId] where user.screenName != nil {
                            self.statusLabel.text = "Invitation sent to \(user.screenName!)"
                        } else {
                            User.getUserArrayFromIdList([_invite.sentTo], successHandler: { (user: [User]) in
                                guard let screenName = user[0].screenName else {return}
                                self.statusLabel.text = "Invitation sent to \(screenName)"
                            })
                        }
                    } else {
                        if recipientId == "friends" {
                            statusLabel.text = "Searching a gymbuddy in Buddy List"
                        } else if recipientId == "public" {
                            statusLabel.text = "Searching a gymbuddy in Public"
                        }
                    }
                    
                } else {
                    self.statusLabel.text = "Invitation sent to unknown user"
                }
            }
                }}
        }

    }
    
    func checkIsEmptyExercise() -> Bool{
        var isEmpty = false
        if let exercises = plan.exercises {
            if "999" == String(String(exercises[0].id).characters.suffix(3)){
                isEmpty = true
            }
        }
        //isEmpty = true
        return isEmpty
    }
    
    func checkIsTracked() -> Bool{
        var isTracked = false
        if(self.trackedPlan != nil){
            isTracked = true
        }
        //isEmpty = true
        return isTracked
    }
    
    func onGymButton (sender: UIButton) {
        print("Placeid :")
        print(self.gym!.placeid)
        guard let placeId = self.gym!.placeid else {
            return
        }
        
        GoogleAPI.sharedInstance.getGymById(placeId) { (gym, error) in
            if error == nil {
                self.performSegueWithIdentifier("toGymMapSegue", sender: gym)
            } else {
                print(error)
            }
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
        if sendTo == "friends" || sendTo == "public"{
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
        if segue.identifier == "toInviteMainSegue" {
            if let desNC = segue.destinationViewController as? UINavigationController,
                let desVC = desNC.topViewController as? InviteMainVC {
                desVC.workoutId = workout.id
                desVC.plan = plan
                desVC.time = selectedDate
                desVC.setNavBarItem()
                desVC.planDetailDelegate = self
            }
        }
        
        if segue.identifier == "startWorkoutSegue" {
            let desNC = segue.destinationViewController as! UINavigationController
            let desVC = desNC.topViewController as! TrackMainVC
            desVC.trackedPlan = TrackedPlan(scheduledWorkout: self.workout.id, plan: plan)
            desVC.gym = self.gym
            desVC.delegate = self
        }
        
        if segue.identifier ==  "toExerciseDetailSegue" {
            if let desVC = segue.destinationViewController as? PlanExerciseVC {
                if let exercises = plan.exercises {
                    desVC.exercise = exercises[sender as! Int]
                }
            }
        }

        if let desVC = segue.destinationViewController as? PlanMainVC {
            print("Going to PlanMainVC")
            if let send = sender as? String {
                if send == "delete" || send == "repeat"{
                    desVC.reloadPlans(desVC.selectedDate)
                }
            }
        }
        
        if let desVC = segue.destinationViewController as? GymMapVC {
            desVC.gym = Gym()
            //desVC.userLocation = CLLocation(latitude: 30.562, longitude: -96.313)
        }
        
        if let checkInVC = segue.destinationViewController as? CheckinVC {
            print("checkInVC")
            checkInVC.delegate = self
            self.startTime = NSDate()
        }
    }
    
    func reloadPlan() {
        KRProgressHUD.show()
        
        let currentDate = NSDate()
        let getTrackedItemGroup = dispatch_group_create()
        if (selectedDate < currentDate || dateToString(selectedDate) == dateToString(currentDate)) {
            dispatch_group_enter(getTrackedItemGroup)
            Tracking.getTrackedPlanById(String(workout.id) + ":" + dateToString(selectedDate)){(result, error) in
                if(result != nil){
                    self.trackedPlan = result
                }
                dispatch_group_leave(getTrackedItemGroup)
            }
            dispatch_group_notify(getTrackedItemGroup, dispatch_get_main_queue()) {
                self.setTableView()
                print("Inside reloadPlan")
                self.setViews(false)
                self.setupVisual()
                self.timeLabel.text = timeString(NSDate())
                self.title = weekMonthDateString(self.selectedDate)
                self.tableView.reloadData()
                KRProgressHUD.dismiss()
            }
            
        }
        ScheduledWorkout.getScheduledWorkoutsById(workout.id) { (workout) in
            self.workout = workout
            Invite.getWorkoutInviteByScheduledWorkoutIdAndDate(workout.id, date: self.selectedDate, completion: { (error: NSError?, invite: Invite?) in
                if let _invite = invite where error == nil {
                    self.workout.invite = _invite
                    self.invite = _invite
                    
                }
                self.viewDidLoad()
                KRProgressHUD.dismiss()
            })
           
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
        //template for set this cell as tracked: testing
        if(!checkIsEmptyExercise()){
        if(checkIsTracked()){
            /*if indexPath.row == 0 {
             cell.setTracked(true)
             }
             //template for set this cell as skipped: testing
             if indexPath.row == 1 {
             cell.setTracked(false)
             }*/
            
            if trackedPlan?.trackingItems[indexPath.row] != nil{
                cell.setTracked((trackedPlan?.trackingItems[indexPath.row].isSkiped)!)
            }else{
                cell.setTracked(true)
            }
            
        }
        
        
        cell.numLabel.text = String(indexPath.row+1)
        if let exercises = plan.exercises {
            cell.exercise = exercises[indexPath.row]
            cell.amountLabel.text = trackedPlan?.trackingItems[indexPath.row].bestRecordStr
        }
            cell.layoutMargins = UIEdgeInsetsZero
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}

extension PlanDetailVC: showCheckInButtonDelegate, showTrackingInfoDelegate {
    
    func showCheckInButton(){
        checkinImage.hidden = false
        checkinLabel.hidden = false
        checkinButton.hidden = true
        timeLocView.hidden = false
        findButton.hidden = true
        saveCheckin()
    }
    
    func saveCheckin(){
        let currentDate = NSDate()
        var trackedItems = [TrackedItem]()
        trackedItems.append(TrackedItem( _exercise: self.plan.exercises![0]))
        Tracking.trackedPlanOnSave(self.workout.id, planId: self.plan.id, startTime: self.startTime, endTime: currentDate, trackedItems: trackedItems, gym: gym!){ (error) in
            if (error != nil){
                print(error)
            }
        }
    }
    
    func showTrackingTable(){
        self.reloadPlan()
    }
}