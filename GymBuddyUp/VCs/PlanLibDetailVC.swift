//
//  PlanDetailVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanLibDetailVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectPlanButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    var plans = [Plan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        collectionView.reloadData()
        
        pageControl?.numberOfPages = plans.count
        pageControl?.currentPage = 0
        pageControl?.userInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPlan(repeating: Bool) {
        //get current displayed plan
        //get current date
        guard let navVC = self.navigationController as? PlanLibNavVC else{
            print("navVC not plan lib nav")
            return
        }
        
        //set if recurring
        let recur = repeating ? 7:0
        //set plan in Firebase
        let cell = collectionView.visibleCells()[0] as! PlanDetailCell
        ScheduledWorkout.addWorkoutToCalendar(cell.plan.id, startDate: navVC.selectedDate, recur: recur) { (error) in
            if error == nil {
                //unwind to plan main
                self.performSegueWithIdentifier("unwindToPlanMainSegue", sender: navVC.selectedDate)
            }else {
                print(error)
            }
        }
        
    }
    
    @IBAction func onSelectPlanButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Repeat this plan?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let WeeklyAction = UIAlertAction(title: "Weekly", style: .Default) { (action) in
            self.setPlan(true)
        }
        alertController.addAction(WeeklyAction)
        
        let NoneAction = UIAlertAction(title: "None", style: .Default) { (action) in
            self.setPlan(false)
        }
        alertController.addAction(NoneAction)

        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Get the current page based on the scroll offset
        let page : Int = Int(round(scrollView.contentOffset.x / self.view.frame.width))
        
        // Set the current page, so the dots will update
        pageControl.currentPage = page
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? PlanMainVC {
            desVC.plans.removeAll()
            desVC.reloadPlans(sender as! NSDate)
        }
    }
 

}

extension PlanLibDetailVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plans.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let detailCell = collectionView.dequeueReusableCellWithReuseIdentifier("PlanDetailCell", forIndexPath: indexPath) as! PlanDetailCell
        let plan = plans[indexPath.row]
        Library.getExercisesByPlanId(plans[indexPath.row].id) { (exercises, error) in
            print("get exercises")
            if let exer = exercises {
                plan.exercises = exer
                detailCell.plan = plan
                detailCell.tableView.reloadData()
            }else {
                print(error)
            }
        }

        return detailCell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let detailCell = cell as? PlanDetailCell else { return }
        detailCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    //Use for size
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    //Use for interspacing
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
}

extension PlanLibDetailVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let exercises = plans[tableView.tag].exercises {
            return exercises.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseNumberedCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        cell.exercise = plans[tableView.tag].exercises![indexPath.row]
        cell.layoutMargins = UIEdgeInsetsZero

        return cell
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ExerciseNumberedCell
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: cell.exercise)
    }
}
