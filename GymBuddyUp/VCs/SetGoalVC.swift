//
//  SetGoalVC.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import ChameleonFramework
class SetGoalVC: UIViewController {
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var loseWeightButton: UIButton!

    @IBOutlet weak var keepFitButton: UIButton!
    @IBOutlet weak var haveFunButton: UIButton!
    @IBOutlet weak var muscleButton: UIButton!
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var selected = Set<Int>()
    
    var tintColor = ColorScheme.p1Tint
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorScheme.s3Bg
        
        loseWeightButton.tag = 0
        keepFitButton.tag = 1
        haveFunButton.tag = 2
        muscleButton.tag = 3
        setButton(loseWeightButton)
        setButton(keepFitButton)
        setButton(haveFunButton)
        setButton(muscleButton)
        setupVisual()
        // Do any additional setup after loading the view.
    }

    func setButton (button: UIButton) {
        button.makeBorderButton(tintColor, radius: 2.0)
        
        button.addTarget(self, action: #selector(SetGoalVC.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func setupVisual() {
        loginLabel.textColor = ColorScheme.g3Text
        infoLabel.textColor = ColorScheme.g3Text
        nextButton.makeRoundButton()
        loginButton.setTitleColor(tintColor, forState: .Normal)
        nextButton.enabled = false
    }
    
    func buttonClicked(sender:UIButton) {
        nextButton.enabled = true
        nextButton.backgroundColor = tintColor
        sender.selected = !sender.selected
        if (sender.selected) {
            selected.insert(sender.tag)
            sender.backgroundColor = tintColor
            sender.setTitleColor(ColorScheme.s4Bg, forState: .Normal)
        }else {
            selected.remove(sender.tag)
            sender.setTitleColor(tintColor, forState: .Normal)
            sender.backgroundColor = ColorScheme.s4Bg
        }
    }
    
    @IBAction func onCompleteButton(sender: AnyObject) {
        User.currentUser?.updateProfile("goal", value: self.selected)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
