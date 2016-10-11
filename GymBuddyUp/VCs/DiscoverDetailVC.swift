//
//  DiscoverDetailVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DiscoverDetailVC: UIViewController {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planDifView: UIImageView!
    @IBOutlet weak var planDifLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gymButton: UIButton!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var planButton: UIButton!
    @IBOutlet weak var joinStack: UIStackView!
    @IBOutlet weak var stackJoinButton: UIButton!
    @IBOutlet weak var stackRejectButton: UIButton!

    var event: Invite!
    var plan = Plan()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(DiscoverDetailVC.profileTapped(_:)))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(DiscoverDetailVC.profileTapped(_:)))
        profileView.addGestureRecognizer(tapGestureRecognizer)
        nameLabel.addGestureRecognizer(tapGestureRecognizer2)
        profileView.userInteractionEnabled = true
        nameLabel.userInteractionEnabled = true
        
        borderView.layer.cornerRadius = 5
        statusLabel.text = "Broadcast to Public"
        setupTableView()
        setupVisual()
        if event != nil {
            setupData()
        }
    }
    
    func setupData() {
        timeLabel.text = weekMonthDateString(event.workoutTime)+", "+timeString(event.workoutTime)
        
        planNameLabel.text = plan.name
        guard let dif = plan.difficulty?.description else {
            return
        }
        planDifLabel.text = dif
        planDifView.image = UIImage(named: dif)
    }
    
    override func viewDidAppear(animated: Bool) {
        setupViews()
    }
    
    func resetActionButton () {
        joinButton.hidden = true
        joinStack.hidden = true
        planButton.hidden = true
    }
    
    func setupVisual() {
        
        self.view.backgroundColor = ColorScheme.s3Bg
        profileView.makeThumbnail(ColorScheme.p1Tint)
        statusLabel.textColor = ColorScheme.g2Text
        gymButton.tintColor = ColorScheme.p1Tint
        joinButton.makeBotButton()
        stackJoinButton.makeBotButton()
        stackRejectButton.makeBotButton(ColorScheme.e1Tint)
        planButton.makeBotButton()
        tableView.separatorColor = ColorScheme.g3Text
        
        let heading = FontScheme.H2
        let text = FontScheme.T3
        nameLabel.font = heading
        goalLabel.font = text
        statusLabel.font = text
        planNameLabel.font = heading
        planDifLabel.font = text
        timeLabel.font = text
        gymButton.titleLabel?.font = FontScheme.T2
    }
    
    func setupViews() {
        statusView.layer.addBorder(.Bottom, color: ColorScheme.g2Text, thickness: 0.5)
        planView.layer.addBorder(.Bottom, color: ColorScheme.g2Text, thickness: 0.5)
        
        resetActionButton()
        joinStack.hidden = false
        if let user = UserCache.sharedInstance.cache[event.inviterId] {
            nameLabel.text = user.screenName
            Log.info("cache HIT")
            if let photoURL = user.photoURL where user.cachedPhoto == nil {
                let request = NSMutableURLRequest(URL: photoURL)
                profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                    self.profileView.image = response.result.value
                    user.cachedPhoto = response.result.value
                }
            } else {
                profileView.image = user.cachedPhoto
            }
        } else {
            User.getUserArrayFromIdList([event.inviterId]) { (users: [User]) in
                    let user = users[0]
                    UserCache.sharedInstance.cache[self.event.inviterId] = user
                    self.nameLabel.text = user.screenName
                    if let photoURL = user.photoURL {
                        let request = NSMutableURLRequest(URL: photoURL)
                        self.profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                            self.profileView.image = response.result.value
                            user.cachedPhoto = response.result.value
                        }
                        
                    }
            }
        }
    }
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: "ExerciseNumberedCell", bundle: nil), forCellReuseIdentifier: "ExerciseNumberedCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        if plan.exercises?.count == 0 {
            print("plan exercise nil")
            tableView.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onChatButton(sender: AnyObject) {
            //        self.hidesBottomBarWhenPushed = true
            self.tabBarController?.tabBar.hidden = true
            self.tabBarController?.tabBar.translucent = true
            Log.info("asdasdasd")
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let secondViewController = storyboard.instantiateViewControllerWithIdentifier("chatVC") as! ChatViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
            InboxMessage.test()
            //        self.hidesBottomBarWhenPushed = false
    }
    
    @IBAction func onJoinButton(sender: AnyObject) {
        //join this workout invite
        
        self.dismissViewControllerAnimated(true, completion: nil)
        let statusView = StatusView()
        statusView.displayView()
        
    }
    
    @IBAction func onRejectButton(sender: AnyObject) {
        //reject invite
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onPlanButton(sender: AnyObject) {
        
    }

    func profileTapped (sender: AnyObject?) {
        self.performSegueWithIdentifier("toProfileSegue", sender: self)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? GymMapVC {
            desVC.gym = Gym()
            desVC.userLocation = CLLocation(latitude: 30.562, longitude: -96.313)
        }
        if let desVC = segue.destinationViewController as? PlanExerciseVC {
            guard let exers = plan.exercises, let row = sender as? Int else {
                return
            }
            desVC.exercise = exers[row]
        }
    }
 

}

extension DiscoverDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let exers = plan.exercises else{
            return 0
        }
        return exers.count

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseNumberedCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        guard let exers = plan.exercises else {
            return cell
        }
        cell.exercise = exers[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}
