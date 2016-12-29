//
//  MeMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 7/6/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import KRProgressHUD
import Alamofire
import AlamofireImage

class MeMainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let kHeaderHeight:CGFloat = 150
    let profileRadius:CGFloat = 125
    let titleBGView: UIImageView = UIImageView()
    let profileView : UIImageView = UIImageView()

    var user: User!
    var cells = ["ProfileCell", "UserBuddyOverviewCell", "WorkoutCell", "WorkoutHistoryCell"]
    var workOuts: [ScheduledWorkout] = []
    var trackings: [TrackedPlan] = []
    var isCurrent = true
    override func viewDidLoad() {

        super.viewDidLoad()
        if user == nil {
            Log.info("show currentUser's info")
            user = User.currentUser
        }
        
    
        if(user.userId != User.currentUser?.userId){
            isCurrent = false
            self.title = " "
            self.navigationItem.rightBarButtonItem = UIBarButtonItem()
        }
        //editProfileButton.hidden = !isCurrent

        setHistory()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 230
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        // Do any additional setup after loading the view.
        setHeader()
    }
    override func viewDidAppear(animated: Bool) {
        print("Enter MeMainVC")
        
        setHistory()
    }
    
    @IBAction func psButton(sender: AnyObject) {
        if let  currentUserId = User.currentUser?.userId,
                recipientUserId = user?.userId,
                senderName = User.currentUser?.screenName {
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let chatVC = storyboard.instantiateViewControllerWithIdentifier("chatVC") as! ChatViewController
            chatVC.setup(currentUserId, senderName: senderName, setupByRecipientId: recipientUserId, recipientName: user?.screenName)
            self.navigationController?.pushViewController(chatVC, animated: true)
        }

    }
    
    private func fetchAvatar(url: NSURL) {
        let request = NSMutableURLRequest(URL: url)
        titleBGView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "dumbbell"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
        self.titleBGView.image = response.result.value
        }
        
        profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "dumbbell"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
        self.profileView.image = response.result.value
        }
    }
    
    func setHeader() {
        titleBGView.image = UIImage(named: "dumbbell")
        profileView.image = UIImage(named: "dumbbell")
        if let photoURL = user.photoURL {
            fetchAvatar(photoURL)
        } else {
            if let currentUser = User.currentUser
            {
                if currentUser.userId == user.userId {
                    User.currentUser?.syncWithLastestUserInfo({
                        if let photoURL = self.user.photoURL {
                            self.fetchAvatar(photoURL)
                        }
                    })
                }
            }
        }

        let headerW = CGRectGetWidth(self.view.frame)
        profileView.frame = CGRect(x: headerW/2 - headerW/6, y: kHeaderHeight - profileRadius / 2.0, width: profileRadius, height: profileRadius)
        profileView.makeThumbnail(ColorScheme.p1Tint)
        if(isCurrent){
            let tap = UITapGestureRecognizer(target: self, action: #selector(MeMainVC.tapProfile(_:)))
            profileView.addGestureRecognizer(tap)
        }
        profileView.userInteractionEnabled = true
        //title background
        self.titleBGView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight)
        self.titleBGView.contentMode = .ScaleAspectFill
        self.titleBGView.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = .FlexibleHeight
        blurEffectView.alpha = 0.7
        self.titleBGView.addSubview(blurEffectView)
        
        let tableHeaderView = UIView(frame: CGRectMake(0, 0, headerW, kHeaderHeight))
        tableHeaderView.backgroundColor = ColorScheme.s3Bg
        tableHeaderView.addSubview(self.titleBGView)
        tableHeaderView.addSubview(self.profileView)
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.tableHeaderView = tableHeaderView

    }

    func setHistory(){
        let eMonth = NSDate()
        let sMonth = (1.years).agoFromDate(eMonth.startOf(.Month))
        let getScheduledWorkoutGroup = dispatch_group_create()
        dispatch_group_enter(getScheduledWorkoutGroup)
        Tracking.getTrackedPlanTimeSpan(sMonth, endDate: eMonth){ (trackedPlans, error) in
            print("getTrackedPlanTimeSpan " +  String(trackedPlans?.count))
            if let trackedPlans = trackedPlans {
                self.trackings = trackedPlans
                //print("getTrackedPlanTimeSpan " + (trackedPlans[0].plan?.name)!)
                self.user.workoutNum = trackedPlans.count
                self.tableView.reloadData()
            }else {
                print(error)
            }
            dispatch_group_leave(getScheduledWorkoutGroup)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMeMainVC(segue: UIStoryboardSegue) {
        
    }
    
    func tapProfile (sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func onActionButton (sender: UIButton) {
        self.performSegueWithIdentifier("toEditProfileSegue", sender: sender)
    }
    
    func onBuddyButton (sender: UIButton) {
        self.performSegueWithIdentifier("ToBuddyProfileSegue", sender: sender)
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let updateVC = segue.destinationViewController as? MeUpdateVC {
            updateVC.user = self.user
            updateVC.delegate = self
        }
    }
}

extension MeMainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + trackings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cells[indexPath.row], forIndexPath: indexPath) as! UserProfileCell
            let asyncId = user.userId
            cell.asyncIdentifer = asyncId
            cell.user = user
            cell.nameLabel.text = user?.screenName
            cell.gymLabel.text = "Not Specific"
            cell.chatButton.hidden = true
            cell.actionButton.hidden = !isCurrent
            if asyncId != User.currentUser?.userId {
                cell.chatButton.hidden = false
            }
            
            if let googleGymObj = user?.googleGymObj {
                cell.gymLabel.text = googleGymObj.name
            } else if let gymName = user?.gym {
                cell.gymLabel.text = gymName
            }

            cell.actionButton.addTarget(self, action: #selector(MeMainVC.onActionButton(_:)), forControlEvents: .TouchUpInside)
            cell.selectionStyle = .None
            return cell
        }else if indexPath.row == cells.count - 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cells[indexPath.row], forIndexPath: indexPath) as! UserBuddyOverviewCell
            cell.user = user
            cell.selectionStyle = .None
            print("Enter UserBuddyOverviewCell")
            return cell
        }else if indexPath.row == cells.count - 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cells[indexPath.row], forIndexPath: indexPath) as! UserWorkoutOverviewCell
            cell.selectionStyle = .None
            print("Enter UserWorkoutOverviewCell" + String(indexPath.row))
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cells[3], forIndexPath: indexPath) as! UserWorkoutHistoryCell
            print("Enter UserWorkoutHistoryCell" + String(indexPath.row))
            if( trackings.count > (indexPath.row - 3 )){
                cell.timeLabel.text = dateToString(trackings[trackings.count - 1 - indexPath.row + 3].startDate!)
                cell.workoutLabel.text = trackings[trackings.count - 1 - indexPath.row + 3].plan?.name
                cell.buddyButton.setTitle("", forState: UIControlState.Normal)
                
            //cell.buddyButton.addTarget(self, action: #selector(MeMainVC.onBuddyButton(_:)), forControlEvents: .TouchUpInside)
            }
            
            return cell
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if let _ = tableView.cellForRowAtIndexPath(indexPath) as? UserBuddyOverviewCell {
            self.performSegueWithIdentifier("toBuddySegue", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yPos: CGFloat = -scrollView.contentOffset.y
        
        if (yPos > 0) {
            var imgRect: CGRect = self.titleBGView.frame
            imgRect.origin.y = scrollView.contentOffset.y
            imgRect.size.height = kHeaderHeight+yPos
            self.titleBGView.frame = imgRect
        }
    }
}

extension MeMainVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        let image = editedImage.imageScaledToSize(CGSizeMake(500, 500))
        profileView.image = image
        titleBGView.image = image
        
        //TODO: dont know why it's failing
        //KRProgressHUD.show()
        user.updateProfilePicture(image){ error in
            if error != nil {
            print("Error setting profile picture \(error?.localizedFailureReason)")
            //KRProgressHUD.showError()
            } else {
                //KRProgressHUD.dismiss()
                Log.info("Setting successfully!")
                self.tableView.reloadData()
            }
        }
                // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MeMainVC: updateMeDelegate {
    func syncAfterUpdateMe(updatedGymPlaceId: String?, updatedGymObj: Gym?, updatedGoals: Set<Int>, updatedProfile: UIImage?) {
        Log.info("update delegate callback")
        User.currentUser?.googleGymObj = updatedGymObj
        User.currentUser?.gym = updatedGymPlaceId
        for goal in updatedGoals {
            User.currentUser?.goals.append(User.Goal(rawValue: goal)!)
        }
        User.currentUser?.syncWithLastestUserInfo(nil)
        self.titleBGView.image = updatedProfile
        self.profileView.image = updatedProfile
        self.tableView.reloadData()
    }
}
