//
//  PlanMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanMainVC: UIViewController {
    @IBOutlet weak var calCollectionView: UICollectionView!
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var repeatPrevButton: UIButton!

    var showPlan = false
    var exercises = ["Jogging", "Barbell", "Bench Press"] //TMP
    override func viewDidLoad() {
        super.viewDidLoad()
        repeatPrevButton.enabled = false
        repeatPrevButton.hidden = true
        
        calCollectionView.dataSource = self
        calCollectionView.delegate = self
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        planView.hidden = !showPlan

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToPlanMainVC(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func onMoreButton(sender: AnyObject) {
         let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let DeleteAction = UIAlertAction(title: "Delete Plan", style: .Destructive) { (action) in
            self.planView.hidden = true
        }
        alertController.addAction(DeleteAction)
        
        let RepeatAction = UIAlertAction(title: "Repeat Plan", style: .Default) { (action) in
            //set plan as repeat
        }
        alertController.addAction(RepeatAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    @IBAction func onNewPlanButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
//        let alertController = UIAlertController(title: nil, message: "New Plan", preferredStyle: .ActionSheet)
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
//            // ...
//        }
//        alertController.addAction(cancelAction)
//        
//        let BuildAction = UIAlertAction(title: "Build your own", style: .Default) { (action) in
//            self.performSegueWithIdentifier("toBuildPlanSegue", sender: self)
//        }
//        alertController.addAction(BuildAction)
//        
//        let LibAction = UIAlertAction(title: "SideKck training library", style: .Default) { (action) in
//            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
//        }
//        alertController.addAction(LibAction)
//        
//        self.presentViewController(alertController, animated: true) {
//            // ...
//        }
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

extension PlanMainVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dateCell = collectionView.dequeueReusableCellWithReuseIdentifier("DateCell", forIndexPath: indexPath)
        return dateCell
    }
}

extension PlanMainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        cell.thumbnailView.image = UIImage(named: "dumbbell")
        cell.nameLabel.text = exercises[indexPath.row]
        return cell
    }
}

