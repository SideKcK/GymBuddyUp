//
//  PlanExerciseVC.swift
//  GymBuddyUp
//
//  Created by you wu on 7/30/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class PlanExerciseVC: UITableViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var mgView: UIImageView!
    @IBOutlet weak var muscleLabel: UILabel!

    var exercise = Exercise()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mgView.hidden = true
        muscleLabel.hidden = true
        nameLabel.text = exercise.name
        desLabel.text = exercise.description
        
        gifView.image = UIImage.gifWithURL(String(exercise.gifURL))
        //
        //gifView.hidden = true
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

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
        let height = ceil(cell.systemLayoutSizeFittingSize(CGSizeMake(self.tableView.bounds.size.width, 1), withHorizontalFittingPriority: 1000, verticalFittingPriority: 1).height)
        return height
    }
}
