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

class DiscoverMainVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var findLabel: UILabel!
    
    
    @IBOutlet weak var segHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var findButtonConstraint: NSLayoutConstraint!
    
    var locationManager: CLLocationManager!
    var currentLocation = CLLocation()
    var events = [PublishedWorkout]()
    var plans = [Plan]()
    var showPublic = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupVisual()
        setupLocation()
        setupTableView()
        addSegControl(segView)
        self.findButtonConstraint.constant = self.view.frame.height / 3.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.tabBarController?.tabBar.translucent = false
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
    }
    
    func setupLocation () {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
    }
    
    
        
    
    func setupTableView () {
        tableView.registerNib(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        tableView.estimatedRowHeight = 120
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
        findButtonConstraint.constant = 20
        findButton.hidden = showPublic
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
        self.events.removeAll()
        self.plans.removeAll()
        if self.events.count == 0 {
            self.findButtonConstraint.constant = self.view.frame.height / 3.0
        }
        self.tableView.reloadData()
    }
    
    func reloadPublicDiscover() {
        KRProgressHUD.show()
        Discover.discoverPublicWorkout(currentLocation, radiusInkilometers: 100.0, withinDays: 3, offset: 0, completion: { (workouts, error) in
            if error != nil{
                Log.error(error.debugDescription)
                KRProgressHUD.showError(message: "Network error")
            }else {
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
        
        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            if KRProgressHUD.isVisible {
                KRProgressHUD.showError(message: "Network Error")
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
            }else {
                print(error)
            }
        }
        
    }
    
    func profileTapped (sender: AnyObject? ) {
        self.performSegueWithIdentifier("toProfileSegue", sender: self)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if events.count != 0 {
        let yDirection = scrollView.panGestureRecognizer.velocityInView(scrollView).y
        if (yDirection < 0) {
            UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
                self.findButton.alpha = 0
                self.segHeightConstraint.priority = 999
                self.segView.alpha = 0
                }, completion: nil)
        }
        else if (yDirection > 0) {
            UIView.animateWithDuration(0.1, delay: 0.2, options: .CurveEaseIn, animations: {
                self.findButton.alpha = 1
                self.segHeightConstraint.priority = 250
                self.segView.alpha = 1
                }, completion: nil)
            
        }
        }

    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navVC = segue.destinationViewController as? UINavigationController,
            let desVC = navVC.topViewController as? DiscoverDetailVC,
            let row = sender as? Int {
                desVC.event = events[row]
                desVC.plan = plans[row]
            }
        if let desVC = segue.destinationViewController as? GymMapVC,
            let gym = sender as? Gym{
            desVC.userLocation = locationManager.location
            desVC.gym = gym
        }
    }


}

extension DiscoverMainVC: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            if let location = manager.location {
                currentLocation = location
                reloadData()
            }
            //print(manager.location)
        }
    }
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            //upload user location
//        }
//        
//    }
}

extension DiscoverMainVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
        guard let location = locationManager.location else{
            return cell
        }
        cell.event = events[indexPath.row]
        cell.gymDisLabel.text = String(round(cell.event.gym!.location!.distanceFromLocation(location) / 1609.34))+" miles"
        cell.plan = plans[indexPath.row]
        
        cell.gymButton.tag = indexPath.row
        cell.gymButton.addTarget(self, action: #selector(DiscoverMainVC.onGymButton), forControlEvents: .TouchUpInside)
        cell.profileTapView.tag = indexPath.row
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(DiscoverMainVC.profileTapped(_:)))
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
            cell.borderView.backgroundColor = ColorScheme.greyText
            UIView.animateWithDuration(0.1, delay: 0.3, options: .CurveEaseIn, animations: {
                    cell.borderView.backgroundColor = UIColor.whiteColor()
                }, completion: nil)
        }
        
    }

}