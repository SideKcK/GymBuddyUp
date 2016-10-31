//
//  DiscoverMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation
import HMSegmentedControl
import KRProgressHUD
import Alamofire
import AlamofireImage

class DiscoverMainVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var findLabel: UILabel!
    
    
    @IBOutlet weak var segHeightConstraint: NSLayoutConstraint!
    var refreshControl: UIRefreshControl!

    
    var events = [Invite]() {
        didSet {
            if events.count > 0 {
                findButton.hidden = true
                findLabel.hidden = true
            } else {
                findButton.hidden = false
                findLabel.hidden = false
            }
        }
    }
    
    var plans = [Plan]()
    var userCache = UserCache.sharedInstance.cache
    var showPublic = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavBar()
        setupVisual()
        setupTableView()
        addSegControl(segView)
        reloadData()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.tabBarController?.tabBar.translucent = false
    }
    
    func setupViews() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        reloadData()
        refreshControl.endRefreshing()
    }
    
    func setupVisual() {
        tableView.backgroundColor = ColorScheme.s3Bg
        findButton.makeActionButton()
        findLabel.textColor = ColorScheme.g2Text
    }
    
    func setupNavBar() {
        let logo = UIImage(named: "Logo_white")!
        let imageView = UIImageView(frame:CGRectMake(0, 0, 30, 30))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = logo
        self.navigationItem.titleView = imageView
        let findNewButton = UIButton()
        findNewButton.setImage(UIImage(named: "find_new_buddy"), forState: .Normal)
        findNewButton.frame = CGRectMake(0, 0, 30, 30)
        findNewButton.addTarget(self, action: #selector(findNewButtonOnClick), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem(customView: findNewButton)
        navigationItem.rightBarButtonItem = rightBarButton
        
    }
    
    func findNewButtonOnClick() {
        performSegueWithIdentifier("toFindBuddiesSegue", sender: nil)
    }
    
    func setupTableView () {
        tableView.registerNib(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }

    func addSegControl (view: UIView) {
        let segControl = HMSegmentedControl(sectionTitles: ["BUDDIES", "PUBLIC"])
        segControl.customize()
        segControl.backgroundColor = ColorScheme.s4Bg
        segControl.frame = CGRectMake(0, 0, self.view.frame.width, view.frame.height)
        view.addSubview(segControl)
        segControl.addTarget(self, action: #selector(DiscoverMainVC.onSegControl(_:)), forControlEvents: .ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onSegControl (sender: HMSegmentedControl) {
        showPublic = !showPublic
        if showPublic {
            findButton.hidden = true
            findLabel.hidden = true
        }
        reloadData()
    }
    
    func reloadData() {
        if showPublic {
            reloadPublicDiscover()
        }else {
            reloadBuddiesDiscover()
        }
    }
    
    func reloadBuddiesDiscover() {
        KRProgressHUD.show()
        
        Discover.discoverFriendsWorkout(5, completion: { (workouts, error) in
            if error != nil{
                Log.error(error.debugDescription)
                KRProgressHUD.showError(message: "Network error")
            } else {
                self.events = workouts
                
                var planids = [String]()
                for workout in workouts {
                    planids.append(workout.planId)
                }
                
                //get plans
                Library.getPlansById(planids, completion: { (plans, error) in
                    if error != nil {
                        Log.error(error.debugDescription)
                        KRProgressHUD.showError(message: "Network error")
                    }else {
                        self.plans = plans
                        self.tableView.reloadData()
                        
                        KRProgressHUD.dismiss()
                    }
                })
                
            }
        })

    }
    
    func reloadPublicDiscover() {
        KRProgressHUD.show()
        let currentLocation = LocationCache.sharedInstance.currentLocation
        Discover.discoverPublicWorkout(currentLocation, radiusInkilometers: 100.0, withinDays: 3, offset: 0, completion: { (workouts, error) in
            if error != nil{
                Log.error(error.debugDescription)
                KRProgressHUD.showError(message: "Network error")
            } else {
                self.events = workouts
                var planids = [String]()
                for workout in workouts {
                    planids.append(workout.planId)
                }
                
                //get plans
                Library.getPlansById(planids, completion: { (plans, error) in
                    if error != nil {
                        Log.error(error.debugDescription)
                        KRProgressHUD.showError(message: "Network error")
                    }else {
                        self.plans = plans
                        self.tableView.reloadData()
                        KRProgressHUD.dismiss()
                    }
                })
                
            }
        })

    }
    
    func onGymButton (sender: UIButton) {
        guard let placeId = events[sender.tag].gym?.placeid else {
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
    
    func profileTapped (sender: AnyObject?) {
        guard let tapLocation = sender?.locationInView(self.tableView) else {return}
        //using the tapLocation, we retrieve the corresponding indexPath
        guard let indexPath = self.tableView.indexPathForRowAtPoint(tapLocation) else {return}
        
        let event = events[indexPath.row]
        
        if let user = UserCache.sharedInstance.cache[event.inviterId] {
            self.performSegueWithIdentifier("toProfileSegue", sender: user)
        } else {
            User.getUserArrayFromIdList([event.inviterId]) { (users: [User]) in
                let user = users[0]
                UserCache.sharedInstance.cache[event.inviterId] = user
                self.performSegueWithIdentifier("toProfileSegue", sender: user)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toProfileSegue" {
            if let desVC = segue.destinationViewController as? MeMainVC {
                desVC.user = sender as? User
                return
            }
        }
        
        if let navVC = segue.destinationViewController as? UINavigationController,
            let desVC = navVC.topViewController as? DiscoverDetailVC,
            let row = sender as? Int {
                desVC.event = events[row]
                desVC.plan = plans[row]
            }
        
        if let desVC = segue.destinationViewController as? GymMapVC,
            let gym = sender as? Gym {
            let currentLocation = LocationCache.sharedInstance.currentLocation
            desVC.userLocation = currentLocation
            desVC.gym = gym
        }
    }
}


extension DiscoverMainVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
        
        print("indexPath.row : " + String(indexPath.row))
        print("workouts.count:" + String(events.count))
        let event = events[indexPath.row]
        cell.invite = events[indexPath.row]
        cell.plan = plans[indexPath.row]
        let asyncId = event.id
        cell.asyncIdentifer = asyncId
        if let user = UserCache.sharedInstance.cache[event.inviterId] {
            cell.profileLabel.text = user.screenName
            
            if let photoURL = user.photoURL where user.cachedPhoto == nil {
                let request = NSMutableURLRequest(URL: photoURL)
                cell.profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "dumbbell"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                    if asyncId == cell.asyncIdentifer {
                        cell.profileView.image = response.result.value
                        user.cachedPhoto = response.result.value
                    }
                }
            } else {
                cell.profileView.image = user.cachedPhoto ?? UIImage(named: "dumbbell")
            }
        } else {
            User.getUserArrayFromIdList([event.inviterId]) { (users: [User]) in
                if asyncId == cell.asyncIdentifer {
                    let user = users[0]
                    UserCache.sharedInstance.cache[event.inviterId] = user
                    cell.profileLabel.text = user.screenName
                    if let photoURL = user.photoURL {
                        let request = NSMutableURLRequest(URL: photoURL)
                        cell.profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "dumbbell"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                            if asyncId == cell.asyncIdentifer {
                                cell.profileView.image = response.result.value
                                user.cachedPhoto = response.result.value
                            }
                        }

                    }
                }
            }
        }
        
        cell.gymButton.tag = indexPath.row
        cell.gymButton.addTarget(self, action: #selector(onGymButton), forControlEvents: .TouchUpInside)

        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(profileTapped(_:)))
        cell.profileTapView.addGestureRecognizer(tapGestureRecognizer)
        
        cell.showProfileView()
        cell.showTimeView()
        cell.showLocView()
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("ToInviteDetailSegue", sender: indexPath.row)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? WorkoutCell {
            cell.borderView.backgroundColor = ColorScheme.g3Text
            UIView.animateWithDuration(0.1, delay: 0.3, options: .CurveEaseIn, animations: {
                    cell.borderView.backgroundColor = UIColor.whiteColor()
                }, completion: nil)
        }
        
    }

}