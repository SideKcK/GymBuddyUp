//
//  MeFindVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import HMSegmentedControl

class MeFindVC: UIViewController {
    @IBOutlet weak var segView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var buddies = [User]() //TODO change to User
    var fbNum = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        print("inside MeFindVC")
        addSegControl(segView)
        setupVisual()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "BuddyCardCell", bundle: nil), forCellReuseIdentifier: "BuddyCardCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        //Friend.discoverNewBuddies(location: CLLocation, radiusInkilometers: Double)([User], NSError?) -> Void)
        getNearByBuddy()
    }

    func setupVisual() {
        segView.backgroundColor = ColorScheme.s3Bg
        tableView.backgroundColor = ColorScheme.s3Bg
    }
    
    func addSegControl (view: UIView) {
        print("addsegcontrol")
        let segControl = HMSegmentedControl(sectionTitles: ["Nearby", "Facebook("+String(fbNum)+")"])
        segControl.customize()
        segControl.frame = CGRectMake(0, 0, self.view.frame.width, view.frame.height)
        view.addSubview(segControl)
        segControl.addTarget(self, action: #selector(MeFindVC.onSegControl(_:)), forControlEvents: .ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func onAddButton (sender: UIButton!) {
        let row = sender.tag
        sender.setTitle("Request Sent", forState: .Normal)
        sender.enabled = false
        print("row : " + String(row))
        Friend.sendFriendRequest(self.buddies[row].userId) { (error: NSError?) in
            if (error != nil) {
                
                
            }
        }
        //send friend request
    }
    
    func onSegControl (sender: HMSegmentedControl) {
        print("seg control" )
        if(sender.selectedSegmentIndex == 0){
            getNearByBuddy()
        }else if(sender.selectedSegmentIndex == 1){
            getFBBuddy()
        }
        
        //tableView.reloadData()
    }
    
    func getNearByBuddy(){
        
        var resultUserList = [User]()
        let fetchNewBuddiesGroup = dispatch_group_create()
        let testLocation = LocationCache.sharedInstance.currentLocation
        //let testLocation = CLLocation(latitude: 30.563, longitude: -96.311)
        dispatch_group_enter(fetchNewBuddiesGroup)
        Friend.discoverNewBuddies(testLocation, radiusInkilometers: 100.0,  completion: { (users, error) in
            if error != nil{
                Log.error(error.debugDescription)
            } else {
                for user in users{
                    if(User.currentUser?.userId != user.userId){
                        if(User.currentUser?.userlocation != nil && user.userlocation != nil){
                            user.distance = User.currentUser?.userlocation!.distanceFromLocation(user.userlocation!)
                        }
                        
                        resultUserList.append(user)
                        
                    }
                    
                }
                
                self.buddies = resultUserList
            }
            dispatch_group_leave(fetchNewBuddiesGroup)
        })
        dispatch_group_notify(fetchNewBuddiesGroup, dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    func getFBBuddy(){
        
        var resultUserList = [User]()
        let fetchNewBuddiesGroup = dispatch_group_create()

        dispatch_group_enter(fetchNewBuddiesGroup)
        Friend.discoverFBFriends({ (users, error) in
            print("users.count: " + String(users.count))
            if error != nil{
                Log.error(error.debugDescription)
            } else {
                for user in users{
                    if(User.currentUser?.userId != user.userId){
                        resultUserList.append(user)
                    }
                    
                }
                print("self.buddies1: " + String(self.buddies.count))
                self.buddies = resultUserList
            }
            dispatch_group_leave(fetchNewBuddiesGroup)
        })
        dispatch_group_notify(fetchNewBuddiesGroup, dispatch_get_main_queue()) {
            print("self.buddies2: " + String(self.buddies.count))
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? MeMainVC {

            //for testing
            let targetUser = sender as? User
            desVC.user = targetUser

        }
    }
 

}

extension MeFindVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCardCell", forIndexPath: indexPath) as! BuddyCardCell
        cell.buddy = buddies[indexPath.row]
        cell.showDistance()
        cell.showAddButton()
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(MeFindVC.onAddButton(_:)), forControlEvents: .TouchUpInside)
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ToBuddyProfileSegue", sender: buddies[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
}
