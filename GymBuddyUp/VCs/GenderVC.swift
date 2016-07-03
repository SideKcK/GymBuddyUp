//
//  GenderVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/22/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class GenderVC: UIViewController {
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var unspecifiedButton: UIButton!
    
    var selected: Gender!
    var checked = [false, false, false]
    
    enum Gender {
        case Male
        case Female
        case Unspecified
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selected = .Male
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMaleButton(sender: UIButton) {
        selected = .Male
        sender.backgroundColor = UIColor.flatGrayColor()
        
    }

    @IBAction func onFemaleButton(sender: UIButton) {
        selected = .Female
        sender.backgroundColor = UIColor.flatGrayColor()

    }
    @IBAction func onUnspecifiedButton(sender: AnyObject) {
        selected = .Unspecified
    }
    
    @IBAction func onNextButton(sender: AnyObject) {
        if selected == Gender.Unspecified {
            //pop up alert
            let alertController = UIAlertController(title: "We recommend gym buddies based on your information", message: "Specify your gender so we can provide you better match. ", preferredStyle: .Alert)
            
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            let SkipAction = UIAlertAction(title: "Skip", style: .Default) { (action) in
                //go to next screen
                self.performSegueWithIdentifier("toSetGoalSegue", sender: sender)
            }
            
            alertController.addAction(OKAction)
            alertController.addAction(SkipAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return

        }else {
            self.performSegueWithIdentifier("toSetGoalSegue", sender: sender)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toSetGoalSegue" {
            //report user gender

        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
