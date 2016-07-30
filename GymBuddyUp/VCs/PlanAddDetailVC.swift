//
//  PlanAddDetailVC.swift
//  GymBuddyUp
//
//  Created by you wu on 7/16/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanAddDetailVC: UIViewController {
    @IBOutlet weak var addPlanButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onAddPlanButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Add more exercise?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let FinishAction = UIAlertAction(title: "Finish", style: .Default) { (action) in
            self.performSegueWithIdentifier("unwindToPlanBuildSegue", sender: self)
        }
        alertController.addAction(FinishAction)
        
        let AddAction = UIAlertAction(title: "Add another", style: .Default) { (action) in
            self.performSegueWithIdentifier("unwindToAddExerciseSegue", sender: self)
        }
        alertController.addAction(AddAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
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
