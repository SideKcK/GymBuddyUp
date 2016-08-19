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

class DiscoverMainVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var segHeightConstraint: NSLayoutConstraint!
    
    var locationManager: CLLocationManager!
    var events = [Plan](count: 20, repeatedValue: Plan())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupLocation()
        setupTableView()
        addSegControl(segView)
    }
    
    func setupNavBar() {
        let logo = UIImage(named: "dumbbell")!
        let imageView = UIImageView(image:logo.resize(CGSize(width: 30, height: 30)))
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
        let segControl = HMSegmentedControl(sectionTitles: ["Buddies", "Public"])
        segControl.customize()
        segControl.backgroundColor = UIColor.whiteColor()
        segControl.frame = CGRectMake(0, 0, self.view.frame.width, view.frame.height)
        view.addSubview(segControl)
        segControl.addTarget(self, action: #selector(DiscoverMainVC.onSegControl(_:)), forControlEvents: .ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onSegControl (sender: HMSegmentedControl) {
        tableView.reloadData()
        findButton.hidden = (sender.selectedSegmentIndex == 1)
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let navVC = segue.destinationViewController as? UINavigationController,
            let desVC = navVC.topViewController as? DiscoverDetailVC {
                desVC.event = sender as? Plan
            }
        }
 

}

extension DiscoverMainVC: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //upload user location
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
        cell.event = events[indexPath.row]
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
        self.performSegueWithIdentifier("ToInviteDetailSegue", sender: events[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}