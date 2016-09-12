//
//  TrackingPopOverViewController.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

@objc protocol TrackingPopOverViewDelegate {
    optional func trackingPopOverView(tableView: UITableView, didSelectItem indexPath: NSIndexPath)
}

class TrackingPopOverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var trackedPlan: TrackedPlan?
    weak var delegate: TrackingPopOverViewDelegate?
    var currentTrackedIndex = 0
    
    override func viewDidLoad() {
        Log.info("viewdidLoad in TrackingPopOverViewController")
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "TrackedItemPopoverCell", bundle: nil), forCellReuseIdentifier: "TrackedItemPopoverCell")
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Log.info("viewWillAppear in TrackingPopOverViewController")
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _trackedItems = trackedPlan?.trackingItems {
            return _trackedItems.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        Log.info("tableView cellForRowAtIndexPath")
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackedItemPopoverCell", forIndexPath: indexPath) as! TrackedItemPopoverCell
        if let trackedItems = trackedPlan?.trackingItems {
            let index = indexPath.row
            cell.exerciseName.text = trackedItems[index].exercise?.name
            let setsAmount = trackedItems[index].setsAmount
            let finishedSets = trackedItems[index].finishedSets
            cell.progressDescriptionLabel.text = "\(finishedSets) of \(setsAmount) sets finished"
            if let iconUrl = trackedItems[index].exercise?.gifURL {
                cell.exerciseIconImageView.af_setImageWithURL(iconUrl)
                cell.exerciseIconImageView.makeThumbnail(ColorScheme.g2Text)
            }
            if index == currentTrackedIndex {
                cell.backgroundColor = ColorScheme.trackingPopOverCurrentItemBg
                cell.exerciseName.textColor = ColorScheme.trackingPopOverCurrentItemTx
                cell.progressDescriptionLabel.textColor = ColorScheme.trackingPopOverCurrentItemTx
            } else {
                cell.backgroundColor = UIColor.clearColor()
                cell.exerciseName.textColor = ColorScheme.trackingPopOverNormalItemTx
                cell.progressDescriptionLabel.textColor = ColorScheme.trackingPopOverNormalItemTx
            }
        }

        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.trackingPopOverView?(tableView, didSelectItem: indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
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
