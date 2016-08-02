//
//  PlanDetailVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanDetailVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectPlanButton: UIButton!

    var plans: [Plan]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPlan(repeating: Bool) {
        //get current displayed plan
        //set plan in Firebase
        let cell = collectionView.visibleCells()[0] as! PlanDetailCell
        cell.plan.setTodayPlan(repeating) { (error: NSError?) in
            //unwind to plan main
            self.performSegueWithIdentifier("unwindToPlanMainSegue", sender: self)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? PlanMainVC {
            let day = desVC.selectedDay
            Plan.getPlan(User.currentUser, date: day.date.convertedDate(), completion: { (plan:Plan!, error: NSError!) in
                if plan != nil {
                    desVC.plan = plan
                    desVC.tableView.reloadData()
                    desVC.planView.hidden = false
                    desVC.workoutButton.hidden = false
                }else {
                    desVC.emptyView.hidden = false
                }
            })
        // Pass the selected object to the new view controller.
        }
    }
 

}

extension PlanDetailVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plans.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let detailCell = collectionView.dequeueReusableCellWithReuseIdentifier("PlanDetailCell", forIndexPath: indexPath) as! PlanDetailCell
            detailCell.plan = plans[indexPath.row]
        return detailCell
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
