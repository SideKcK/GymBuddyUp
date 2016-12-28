//
//  InviteGymVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CoreLocation
import KRProgressHUD

class InviteGymVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var lastGym = Gym()
    var defaultGyms = [Gym(), Gym()]
    var nearbyGyms = [Gym]()
    var totalSections = 1
    var from: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        KRProgressHUD.show()
        let myLocationCoord2D = LocationCache.sharedInstance.currentLocation.coordinate
        GoogleAPI.sharedInstance.fetchPlacesNearCoordinate(myLocationCoord2D, radius: 5000, name: "gym") { (gyms, error) in
            if gyms != nil {
                self.nearbyGyms = gyms
                self.nearbyGyms.sortInPlace({ (a: Gym, b: Gym) -> Bool in
                    var distanceToA = 9999999999999.0
                    var distanceToB = 9999999999999.0
                    if let aLocation = a.location {
                        distanceToA = LocationCache.sharedInstance.currentLocation.distanceFromLocation(aLocation)
                    }
                    if let bLocation = b.location {
                        distanceToB = LocationCache.sharedInstance.currentLocation.distanceFromLocation(bLocation)
                    }
                    
                    return distanceToA < distanceToB
                })
                
                self.tableView.reloadData()
                KRProgressHUD.dismiss()
            }else {
                KRProgressHUD.showError()
                print(error)
            }
        }


        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteMainVC {
            guard let selectedGym = sender as? Gym else {
                return
            }
            desVC.gym = selectedGym
        }
        if let desVC = segue.destinationViewController as? MeUpdateVC {
            guard let selectedGym = sender as? Gym else {
                return
            }
            desVC.gym = selectedGym
            desVC.gym1Button.setTitle(selectedGym.name, forState: .Normal)
        }
     }
    
    
}

extension InviteGymVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if totalSections == 2 {
            if section == 0 {
                return 1
            } else {
                return nearbyGyms.count
            }
        } else {
            return nearbyGyms.count
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GymCell", forIndexPath: indexPath) as! GymCell
        if totalSections == 2 {
            if indexPath.section == 0 {
                cell.gym = User.currentUser?.googleGymObj
            } else if indexPath.section == 1 {
                cell.gym = nearbyGyms[indexPath.row]
            }
        } else {
            cell.gym = nearbyGyms[indexPath.row]
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = User.currentUser?.googleGymObj {
            totalSections = 2
            return totalSections
        }
        return totalSections
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if totalSections == 2 {
            if section == 0 {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
                headerView.backgroundColor = UIColor.flatWhiteColor()
                
                let profileView = UIImageView(frame: CGRect(x: 20, y: 10, width: 20, height: 20))
                profileView.image = UIImage(named: "gym")
                headerView.addSubview(profileView)
                
                let nameLabel = UILabel(frame: CGRect(x: 60, y: 10, width: 150, height: 20))
                nameLabel.clipsToBounds = true
                nameLabel.text = "Current Gym"
                
                nameLabel.font = UIFont.systemFontOfSize(12)
                headerView.addSubview(nameLabel)
                return headerView
            }
        }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        headerView.backgroundColor = UIColor.flatWhiteColor()
        
        let profileView = UIImageView(frame: CGRect(x: 20, y: 10, width: 30, height: 20))
        profileView.image = UIImage(named: "gym")
        headerView.addSubview(profileView)
        
        let nameLabel = UILabel(frame: CGRect(x: 60, y: 10, width: 150, height: 20))
        nameLabel.clipsToBounds = true
        nameLabel.text = "Gym Nearby"
        
        nameLabel.font = UIFont.systemFontOfSize(12)
        headerView.addSubview(nameLabel)
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var gymSelected: Gym?
        if totalSections == 2 {
            if indexPath.section == 0 {
                gymSelected = User.currentUser?.googleGymObj
            } else {
                gymSelected = nearbyGyms[indexPath.row]
            }
        } else if totalSections == 1 {
            gymSelected = nearbyGyms[indexPath.row]
        }
        
        if let _ = from as? MeUpdateVC {
            self.performSegueWithIdentifier("unwindToMeUpdateVC", sender: gymSelected)
        } else {
            self.performSegueWithIdentifier("unwindToInviteMainVC", sender: gymSelected)
        }

    }
}