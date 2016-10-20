//
//  MeBuddiesVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MeBuddiesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var findView: UIView!
    
    var buddies = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Buddies"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "BuddyCardCell", bundle: nil), forCellReuseIdentifier: "BuddyCardCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        setupVisual()
        loadData()
    }
    @IBAction func addFriendOnClick(sender: AnyObject) {
        let navVC = UINavigationController()
        let searchUserVC = SearchUserViewController()
        navVC.pushViewController(searchUserVC, animated: false)
        self.presentViewController(navVC, animated: true) { 
            Log.info("instantiate a new NavVC")
        }
    }

    func loadData() {
        User.currentUser?.getMyFriendList({ (users: [User]) in
            self.buddies = users
            self.tableView.reloadData()
            self.title = "Buddies ("+String(self.buddies.count)+")"
        })
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupVisual() {
        findView.backgroundColor = ColorScheme.s3Bg
        tableView.backgroundColor = ColorScheme.s3Bg
        findButton.layer.cornerRadius = 8
        findButton.backgroundColor = ColorScheme.p1Tint
        findButton.titleLabel?.textColor = ColorScheme.g4Text
        findButton.titleLabel?.font = FontScheme.T2
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToBuddyProfileSegue" {
            if let desVC = segue.destinationViewController as? MeMainVC {
                desVC.user = sender as? User
            }
        }

    }
 

}

extension MeBuddiesVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCardCell", forIndexPath: indexPath) as! BuddyCardCell
        let buddy = buddies[indexPath.row]

        cell.buddy = buddy
        let asyncIdentifer = buddy.userId
        cell.asyncIdentifer = asyncIdentifer
        if let user = UserCache.sharedInstance.cache[asyncIdentifer] {
            if let photoURL = user.photoURL where user.cachedPhoto == nil {
                let request = NSMutableURLRequest(URL: photoURL)
                cell.profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                    if asyncIdentifer == cell.asyncIdentifer {
                        cell.profileView.image = response.result.value
                        user.cachedPhoto = response.result.value
                    }
                }
            } else {
                cell.profileView.image = user.cachedPhoto
            }
        }

        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ToBuddyProfileSegue", sender: buddies[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
