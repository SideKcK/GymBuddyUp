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
    
    var from: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        KRProgressHUD.show()
        GoogleAPI.sharedInstance.fetchPlacesNearCoordinate(CLLocationCoordinate2D(latitude: 30.562, longitude: -96.313), radius: 5000, name: "gym") { (gyms, error) in
            if gyms != nil {
                self.nearbyGyms = gyms
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
        if section == 0 {
            if defaultGyms.indexOf({$0.name == lastGym.name}) == nil {
                return defaultGyms.count
            }else {
                return defaultGyms.count + 1
            }
        }else {
            return nearbyGyms.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GymCell", forIndexPath: indexPath) as! GymCell
        if indexPath.section == 1 {
            cell.gym = nearbyGyms[indexPath.row]
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
            headerView.backgroundColor = UIColor.flatWhiteColor()
            
            let profileView = UIImageView(frame: CGRect(x: 20, y: 10, width: 30, height: 30))
            profileView.image = UIImage(named: "dumbbell")
            headerView.addSubview(profileView)
            
            let nameLabel = UILabel(frame: CGRect(x: 60, y: 10, width: 300, height: 30))
            nameLabel.clipsToBounds = true
            nameLabel.text = "Gym Nearby"
            
            nameLabel.font = UIFont.systemFontOfSize(12)
            headerView.addSubview(nameLabel)
            return headerView
        }
        return nil
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let _ = from as? MeUpdateVC {
            self.performSegueWithIdentifier("unwindToMeUpdateVC", sender: nearbyGyms[indexPath.row])
        }
        
        if indexPath.section == 1 {
            self.performSegueWithIdentifier("unwindToInviteMainVC", sender: nearbyGyms[indexPath.row])
        }
    }
}