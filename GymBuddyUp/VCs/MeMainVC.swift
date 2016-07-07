//
//  MeMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 7/6/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MeMainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let kHeaderHeight:CGFloat = 130
    let titleBGView: UIImageView = UIImageView()
    let profileView : UIImageView = UIImageView()

    let cells = ["ProfileCell", "BuddyCell", "WorkoutCell", "WorkoutHistoryCell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 230
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        // Do any additional setup after loading the view.
        setHeader()
    }
    func setHeader() {
        titleBGView.image = UIImage(named: "selfie")
        profileView.image = UIImage(named: "selfie")
        let headerW = CGRectGetWidth(self.view.frame)

        
        profileView.frame = CGRect(x: headerW/2 - headerW/6, y: kHeaderHeight/2, width: headerW/3, height: headerW/3)
        profileView.clipsToBounds = true
        profileView.contentMode = UIViewContentMode.ScaleAspectFill
        profileView.layer.cornerRadius = headerW/6
        profileView.layer.borderWidth = 2.0
        profileView.layer.borderColor = ColorScheme.sharedInstance.navTint.CGColor
        
        //title background
        self.titleBGView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kHeaderHeight)
        self.titleBGView.contentMode = .ScaleAspectFill
        self.titleBGView.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = .FlexibleHeight
        blurEffectView.alpha = 0.7
        self.titleBGView.addSubview(blurEffectView)
        
        let tableHeaderView = UIView(frame: CGRectMake(0, 0, headerW, kHeaderHeight))
        tableHeaderView.backgroundColor = UIColor.flatWhiteColor()
        tableHeaderView.addSubview(self.titleBGView)
        tableHeaderView.addSubview(self.profileView)
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.tableHeaderView = tableHeaderView

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}

extension MeMainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < 4 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cells[indexPath.row], forIndexPath: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cells[3], forIndexPath: indexPath)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            self.performSegueWithIdentifier("toBuddySegue", sender: self)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yPos: CGFloat = -scrollView.contentOffset.y
        
        if (yPos > 0) {
            var imgRect: CGRect = self.titleBGView.frame
            imgRect.origin.y = scrollView.contentOffset.y
            imgRect.size.height = kHeaderHeight+yPos
            self.titleBGView.frame = imgRect
        }
    }
}