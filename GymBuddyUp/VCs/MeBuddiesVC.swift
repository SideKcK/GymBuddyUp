//
//  MeBuddiesVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MeBuddiesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var findView: UIView!

    var buddies = ["Jesiah", "You", "Aaron"]//TODO change to User
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Buddies ("+String(buddies.count)+")"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "BuddyCardCell", bundle: nil), forCellReuseIdentifier: "BuddyCardCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        setupVisual()
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
        if let desVC = segue.destinationViewController as? MeMainVC {
            //for testing
            //desVC.user = User()
        }
    }
 

}

extension MeBuddiesVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buddies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BuddyCardCell", forIndexPath: indexPath) as! BuddyCardCell
        cell.buddy = buddies[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ToBuddyProfileSegue", sender: buddies[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
