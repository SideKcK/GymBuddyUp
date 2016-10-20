//
//  InviteBuddiesVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class InviteBuddiesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var buddies = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisual()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    func setupVisual() {
        tableView.backgroundColor = ColorScheme.s3Bg
        tableView.separatorColor = UIColor.clearColor()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "BuddyCardCell", bundle: nil), forCellReuseIdentifier: "BuddyCardCell")
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
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteMainVC {
            desVC.sendToUser = sender as? User
        }
    }

}

extension InviteBuddiesVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCardCell", forIndexPath: indexPath) as! BuddyCardCell
        let index = indexPath.row
        let buddy = buddies[index]
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
        
        cell.nameLabel.text = buddy.screenName
        cell.goalLabel.hidden = true
        cell.gymLabel.hidden = true
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("unwindToInviteMainVC", sender: buddies[indexPath.row])
    }
}
