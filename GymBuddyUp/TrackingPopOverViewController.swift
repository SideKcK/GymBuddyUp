//
//  TrackingPopOverViewController.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TrackingPopOverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var trackedPlan: TrackedPlan?
    var trackedItems = [TrackedItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _trackedPlan = trackedPlan {
            Log.info("trackedPlan in PopOver")
            for item in _trackedPlan.trackingItems {
                trackedItems.append(item)
            }
        }

        Log.info("trackedItems in PopOver \(trackedItems.count)")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "TrackedItemPopoverCell", bundle: nil), forCellReuseIdentifier: "TrackedItemPopoverCell")
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackedItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrackedItemPopoverCell", forIndexPath: indexPath) as! TrackedItemPopoverCell
        let index = indexPath.row
        cell.exerciseName.text = trackedItems[index].exercise?.name
        return cell
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
