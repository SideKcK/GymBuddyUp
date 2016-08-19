//
//  DiscoverDetailVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class DiscoverDetailVC: UIViewController {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planDifView: UIImageView!
    @IBOutlet weak var planDifLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gymButton: UIButton!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var tableView: UITableView!

    var event: Plan!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderView.layer.cornerRadius = 5
        planNameLabel.text = event.name
        statusLabel.text = "Broadcast to Public"
        planDifLabel.text = "Beginner"
        setupTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        setupViews()
    }
    
    func setupViews() {
        statusView.layer.addBorder(.Bottom, color: ColorScheme.sharedInstance.greyText, thickness: 0.5)
        planView.layer.addBorder(.Bottom, color: ColorScheme.sharedInstance.greyText, thickness: 0.5)
    }
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: "ExerciseNumberedCell", bundle: nil), forCellReuseIdentifier: "ExerciseNumberedCell")
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onJoinButton(sender: AnyObject) {
        //join this workout invite
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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

extension DiscoverDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exercises = event.exercises {
            return exercises.count
        }else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseNumberedCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        if let exercises = event.exercises {
            cell.exercise = exercises[indexPath.row]
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}
