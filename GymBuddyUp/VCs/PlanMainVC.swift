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

    var plan: Plan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        planView.hidden = true
        calCollectionView.dataSource = self
        calCollectionView.delegate = self
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        Plan.getTodayPlan { (plan:Plan!, error: NSError!) in
            if error == nil {
                self.plan = plan
                self.tableView.reloadData()
                self.planView.hidden = false
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToPlanMainVC(segue: UIStoryboardSegue) {
        Plan.getTodayPlan { (plan:Plan!, error: NSError!) in
            if error == nil {
                self.plan = plan
                self.tableView.reloadData()
                self.planView.hidden = false
            }
        }

    }
    
    @IBAction func onMoreButton(sender: AnyObject) {
         let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            Plan.deleteTodayPlan({ (error) in
                print("deleting plan: \(error)")
                self.planView.hidden = true
            })
        }
        alertController.addAction(DeleteAction)
        
        let ReplaceAction = UIAlertAction(title: "Replace", style: .Default) { (action) in
            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        }
        alertController.addAction(ReplaceAction)
        
        let RepeatAction = UIAlertAction(title: "Repeat Weekly", style: .Default) { (action) in
            //set plan as repeat
            Plan.repeatTodayPlan({ (error) in
                print("set repeat: \(error)")
            })
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier ==  "toExerciseDetailSegue" {
            if let desVC = segue.destinationViewController as? PlanExerciseVC {
                if let plan = plan, exercises = plan.exercises {
                    desVC.exercise = exercises[sender as! Int]
                }
            }
        }
    }
 

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
        if let plan = plan, exercises = plan.exercises {
            return exercises.count
        }else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        if let plan = plan, exercises = plan.exercises {
            cell.exercise = exercises[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}

