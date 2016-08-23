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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(DiscoverDetailVC.profileTapped(_:)))
        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(DiscoverDetailVC.profileTapped(_:)))
        profileView.addGestureRecognizer(tapGestureRecognizer)
        nameLabel.addGestureRecognizer(tapGestureRecognizer2)
        profileView.userInteractionEnabled = true
        nameLabel.userInteractionEnabled = true
        
        borderView.layer.cornerRadius = 5
        planNameLabel.text = event.name
        statusLabel.text = "Broadcast to Public"
        planDifLabel.text = "Beginner"
        setupTableView()
        setupVisual()
    }
    
    override func viewDidAppear(animated: Bool) {
        setupViews()
    }
    
    func setupVisual() {
        self.view.backgroundColor = ColorScheme.s3Bg
        profileView.makeThumbnail(ColorScheme.p1Tint)
        statusLabel.textColor = ColorScheme.g2Text
        gymButton.tintColor = ColorScheme.p1Tint
        tableView.separatorColor = ColorScheme.g3Text
        
        let heading = FontScheme.H1
        let text = FontScheme.T3
        nameLabel.font = heading
        goalLabel.font = text
        statusLabel.font = text
        planNameLabel.font = heading
        planDifLabel.font = text
        timeLabel.font = text
        gymButton.titleLabel?.font = FontScheme.T2
    }
    
    func setupViews() {
        statusView.layer.addBorder(.Bottom, color: ColorScheme.g2Text, thickness: 0.5)
        planView.layer.addBorder(.Bottom, color: ColorScheme.g2Text, thickness: 0.5)
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

    func profileTapped (sender: AnyObject?) {
        self.performSegueWithIdentifier("toProfileSegue", sender: self)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? GymMapVC {
            desVC.gym = Gym()
            desVC.userLocation = CLLocation(latitude: 30.562, longitude: -96.313)
        }
    }
 

}

extension DiscoverDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let exers = event.exercises else{
            return 0
        }
        return exers.count

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseNumberedCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        guard let exers = event.exercises else {
            return cell
        }
        cell.exercise = exers[indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}
