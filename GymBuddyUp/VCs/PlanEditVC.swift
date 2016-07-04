//
//  PlanEditVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanEditVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var showDateVisible = false
    var showRepeatVisible = false

    var cells = ["titleCell", "repeatCell", "detailCell"]
    var cellNum = 9
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0

        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()

        // Do any additional setup after loading the view.
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
extension PlanEditVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellNum
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < cellNum - 6 {
            let cell = tableView.dequeueReusableCellWithIdentifier(cells[indexPath.row], forIndexPath: indexPath)
            return cell
        }else if indexPath.row < cellNum - 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("exerciseCell", forIndexPath: indexPath)
            return cell
        }else {
            let addCell = tableView.dequeueReusableCellWithIdentifier("addCell", forIndexPath: indexPath)
            return addCell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 {
            showRepeatVisible = !showRepeatVisible
            if !showRepeatVisible {
                cellNum -= 1
                cells.removeAtIndex(2)
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }else {
                cellNum += 1
                cells.insert("repeatWeeklyCell", atIndex: 2)
                tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            }

        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}