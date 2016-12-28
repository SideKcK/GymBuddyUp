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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginLaebl: UILabel!
    
    var selected: User.Gender?

    var tintColor = ColorScheme.p1Tint
    var oriColor = ColorScheme.g3Text
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selected = .Unspecified
        setupVisual()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupVisual() {
        self.view.backgroundColor = ColorScheme.s3Bg
        nextButton.makeRoundButton(ColorScheme.p1Tint)
        loginButton.setTitleColor(tintColor, forState: .Normal)
        loginLaebl.textColor = ColorScheme.g3Text
        maleButton.tintColor = ColorScheme.g3Text
        femaleButton.tintColor = ColorScheme.g3Text
        maleLabel.textColor = ColorScheme.g3Text
        femaleLabel.textColor = ColorScheme.g3Text
    }
    
    @IBAction func onMaleButton(sender: UIButton) {
        selected = .Male
        sender.tintColor = tintColor
        maleLabel.textColor = tintColor
        femaleButton.tintColor = oriColor
        femaleLabel.textColor = oriColor
    }

    @IBAction func onFemaleButton(sender: UIButton) {
        selected = .Female
        sender.tintColor = tintColor
        femaleLabel.textColor = tintColor
        maleButton.tintColor = oriColor
        maleLabel.textColor = oriColor
    }
    
    @IBAction func onNextButton(sender: AnyObject) {
        
        if selected == User.Gender.Unspecified {
            //pop up alert
            let alertController = UIAlertController(title: "We recommend gym buddies based on your information", message: "Specify your gender so we can provide you with better match. ", preferredStyle: .Alert)
            alertController.customize()
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            let SkipAction = UIAlertAction(title: "Skip", style: .Default) { (action) in
                //go to next screen
                User.currentUser?.updateProfile("gender", value: self.selected?.hashValue)
                self.performSegueWithIdentifier("toSetGoalSegue", sender: sender)
            }
            
            alertController.addAction(OKAction)
            alertController.addAction(SkipAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return

        }else {
            User.currentUser?.updateProfile("gender", value: self.selected?.hashValue)
            if self.selected == .Female{
                User.currentUser?.updateProfilePicture(UIImage(named: "woman")!){error in
                    print("Error setting profile picture \(error?.localizedFailureReason)")
                }
            }else if self.selected == .Male{
                User.currentUser?.updateProfilePicture(UIImage(named: "man")!){error in
                    print("Error setting profile picture \(error?.localizedFailureReason)")
                }
            }
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
