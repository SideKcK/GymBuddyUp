//
//  TrackMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/1/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TrackMainVC: UIViewController {
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var botButton: UIButton!

    var trackedPlan: TrackedPlan?
    var seconds: Float = 0.0
    var secondTotal: Float = 0.0
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTimer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTimer() {
        seconds = 100.0
        secondTotal = seconds
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = secondToMin(secondTotal)
        timerLabel.text = secondToString(seconds)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(TrackMainVC.subtractTime), userInfo: nil, repeats: true)
    }

    func subtractTime() {
        seconds -= 1.0
        timerLabel.text = secondToString(seconds)
        progressView.setProgress((seconds/secondTotal), animated: true)

        if(seconds == 0)  {
            timer.invalidate()
            botButton.titleLabel?.text = ">>"
            //go to next exercise
        }
    }
    
    @IBAction func onExitButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onDoneButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
