//
//  DoneModalViewController.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class BreakModalViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    var totalBreakTime: Float = 10.0
    var passedBreakTime: Float = 0.0
    var timer = NSTimer()
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var circularProgressBar: RPCircularProgress!
    @IBOutlet weak var breakTimeLabel: UILabel!
    
    @IBOutlet weak var tipTSKLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circularProgressBar.trackTintColor = UIColor.whiteColor()
        circularProgressBar.progressTintColor = ColorScheme.p1Tint
        circularProgressBar.thicknessRatio = 0.05
        
        breakTimeLabel.textColor = UIColor.whiteColor()
        tipTSKLabel.textColor = UIColor.whiteColor()
        remainingTimeLabel.textColor = UIColor.whiteColor()
        
        UIApplication.sharedApplication().statusBarHidden = true
        contentView.backgroundColor = ColorScheme.trackingDoneModalBg
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        
        self.view.insertSubview(blurEffectView, atIndex: 0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(screenTouch(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        remainingTimeLabel.text = "\(Int(totalBreakTime)) s"
        passedBreakTime = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        circularProgressBar.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        // Do any additional setup after loading the view.
    }
    
    func timerCallback() {
        passedBreakTime += 1
        let progressCGFloat = CGFloat(passedBreakTime/totalBreakTime)
        let remainingTimeInt = Int(totalBreakTime - passedBreakTime)
        circularProgressBar.updateProgress(progressCGFloat, animated: true, initialDelay: 0.0, duration: 1.0, completion: nil)
        remainingTimeLabel.text = "\(remainingTimeInt) s"
        if passedBreakTime > totalBreakTime {
            exitThisView()
        }
    }
    
    func exitThisView() {
        if timer.valid {
            timer.invalidate()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func screenTouch(sender: UITapGestureRecognizer) {
        exitThisView()
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
