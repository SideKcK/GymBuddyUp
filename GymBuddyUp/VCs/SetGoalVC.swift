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
    
    
    var buttonViewMap = [Int: UIImageView]()
    var selected = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GradientColor(.Radial, frame: self.view.bounds, colors: [ColorScheme.bgGradientCenter, ColorScheme.bgGradientOut])
        
        loseWeightButton.tag = 0
        keepFitButton.tag = 1
        haveFunButton.tag = 2
        muscleButton.tag = 3
        setButton(loseWeightButton, image: loseWeightView)
        setButton(keepFitButton, image: keepFitView)
        setButton(haveFunButton, image: haveFunView)
        setButton(muscleButton, image: muscleView)
        // Do any additional setup after loading the view.
    }

    func setButton (button: UIButton, image: UIImageView) {
        buttonViewMap[button.tag] = image
        button.addShadow()
        image.makeThumbnail(ColorScheme.s4Bg)
        
        button.addTarget(self, action: #selector(SetGoalVC.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)


    }
    
    func buttonClicked(sender:UIButton)
    {
        sender.selected = !sender.selected
        if (sender.selected) {
            selected.append(sender.tag)
            buttonViewMap[sender.tag]?.tintColor = ColorScheme.p1Tint
        }else {
            buttonViewMap[sender.tag]?.tintColor = ColorScheme.s4Bg
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
