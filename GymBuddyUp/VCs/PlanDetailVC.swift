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
    @IBOutlet weak var usePlanButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPlan(repeating: Bool) {
        //set plan in Firebase
        
        //unwind to plan main
        self.performSegueWithIdentifier("unwindToPlanMainSegue", sender: self)
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
        if let planMainVC = segue.destinationViewController as? PlanMainVC {
            planMainVC.showPlan = true
        }
        // Pass the selected object to the new view controller.
    }
 

}

extension PlanDetailVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let detailCell = collectionView.dequeueReusableCellWithReuseIdentifier("PlanDetailCell", forIndexPath: indexPath)
        return detailCell
    }
}
