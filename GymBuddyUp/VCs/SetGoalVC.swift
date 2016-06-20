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
    @IBOutlet weak var loseWeightButton: UIButton!
    @IBOutlet weak var loseWeightView: UIImageView!

    @IBOutlet weak var keepFitButton: UIButton!
    @IBOutlet weak var keepFitView: UIImageView!
    @IBOutlet weak var haveFunButton: UIButton!
    @IBOutlet weak var haveFunView: UIImageView!
    @IBOutlet weak var muscleButton: UIButton!
    @IBOutlet weak var muscleView: UIImageView!
    
    
    var buttonViewMap = [UIButton: UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GradientColor(.Radial, frame: self.view.bounds, colors: [ColorScheme.sharedInstance.bgGradientCenter, ColorScheme.sharedInstance.bgGradientOut])
        setButton(loseWeightButton, image: loseWeightView)
        setButton(keepFitButton, image: keepFitView)
        setButton(haveFunButton, image: haveFunView)
        setButton(muscleButton, image: muscleView)
        // Do any additional setup after loading the view.
    }

    func setButton (button: UIButton, image: UIImageView) {
        buttonViewMap[button] = image
        let darkColor = ColorScheme.sharedInstance.darkText
        let lightColor = ColorScheme.sharedInstance.lightText
        image.tintColor = lightColor
        image.layer.cornerRadius = image.frame.width/2.0
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor(white: 0.0, alpha: 0.3).CGColor
        
        button.backgroundColor = lightColor
        button.layer.cornerRadius = 5
        //button.clipsToBounds = true
        button.layer.shadowColor = darkColor.CGColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 1
        button.addTarget(self, action: #selector(SetGoalVC.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)


    }
    
    func buttonClicked(sender:UIButton)
    {
        sender.selected = !sender.selected
        if (sender.selected) {
            buttonViewMap[sender]?.tintColor = ColorScheme.sharedInstance.darkText
        }else {
            buttonViewMap[sender]?.tintColor = ColorScheme.sharedInstance.lightText
        }
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
