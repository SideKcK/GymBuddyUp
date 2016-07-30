//
//  PlanBuildVC.swift
//  GymBuddyUp
//
//  Created by you wu on 7/16/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanBuildVC: UIViewController {
    @IBOutlet weak var finishButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToPlanBuildVC(segue: UIStoryboardSegue) {
    }
    
    func setPlan(repeating: Bool) {
        //set plan in Firebase
        
        //unwind to plan main
        self.performSegueWithIdentifier("unwindToPlanMainSegue", sender: self)
    }

    @IBAction func onFinishButton(sender: AnyObject) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
