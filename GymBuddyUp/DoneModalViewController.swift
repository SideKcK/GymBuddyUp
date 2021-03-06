//
//  DoneModalViewController.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class DoneModalViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var onFinishingObjectLabel: UILabel!
    var planName: String?
    var doneCallBack: (()->())?
    
    @IBAction func doneButtonOnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            self.doneCallBack?()
        })
        UIApplication.sharedApplication().statusBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarHidden = true
        congratsLabel.textColor = ColorScheme.p1Tint
        onFinishingObjectLabel.textColor = ColorScheme.p1Tint
        onFinishingObjectLabel.text = planName
        contentView.backgroundColor = ColorScheme.trackingDoneModalBg
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        self.view.insertSubview(blurEffectView, atIndex: 0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
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
