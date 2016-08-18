//
//  TrackMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/1/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import AKPickerView_Swift

class TrackMainVC: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource{
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var botButton: UIButton!
    
    @IBOutlet weak var lbsPicker: AKPickerView!
    
    @IBOutlet weak var repsPicker: AKPickerView!
    
    @IBOutlet weak var lbsLabel: KKParamsLabel!
    @IBOutlet weak var repsLabel: KKParamsLabel!

    @IBOutlet weak var lbsPickerContainer: UIView!
    @IBOutlet weak var repsPickerContainer: UIView!
    
    @IBOutlet weak var gifContainer: UIView!
    
    @IBOutlet weak var gifIcon: UIButton!
    
    
    var trackedPlan: TrackedPlan?
    var seconds: Float = 0.0
    var secondTotal: Float = 0.0
    var timer = NSTimer()
    
    var repsRange = [1, 2, 3, 4, 5, 6, 7, 8]
    var lbsRange = [10, 15, 20, 25, 30, 35, 40]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTimer()
        
        lbsPicker.dataSource = self
        lbsPicker.delegate = self
        repsPicker.dataSource = self
        repsPicker.delegate = self
        lbsPicker.reloadData()
        repsPicker.reloadData()
        lbsPicker.pickerViewStyle = AKPickerViewStyle.Flat
        lbsPicker.interitemSpacing = 20.0
        repsPicker.pickerViewStyle = AKPickerViewStyle.Flat
        repsPicker.interitemSpacing = 20.0

        lbsPicker.maskDisabled = false
        repsPicker.maskDisabled = false
        
        lbsLabel.userInteractionEnabled = true
        let lbsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.paramsTapResponse(_:)))
        lbsLabel.addGestureRecognizer(lbsTapGestureRecognizer)
        
        repsLabel.userInteractionEnabled = true
        let repsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.paramsTapResponse(_:)))
        repsLabel.addGestureRecognizer(repsTapGestureRecognizer)
        
        lbsPickerContainer.layer.shadowOpacity = 0.5
        lbsPickerContainer.layer.shadowRadius = 1
        lbsPickerContainer.layer.shadowOffset = CGSizeMake(0.0, 1.0)
 
        repsPickerContainer.layer.shadowOpacity = 0.5
        repsPickerContainer.layer.shadowRadius = 1
        repsPickerContainer.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        
        lbsPickerContainer.hidden = true
        repsPickerContainer.hidden = true
        
        let closePicker: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closePickerResponse(_:)))
        view.addGestureRecognizer(closePicker)

        // Do any additional setup after loading the view.
    }
    
    
    
    
    func closePickerResponse(recognizer: UITapGestureRecognizer) {
        Log.info("closePickerResponse")
        UIView.animateWithDuration(0.3, animations: {
            self.lbsPickerContainer.hidden = true
            self.repsPickerContainer.hidden = true
            self.gifContainer.hidden = false
        }) { (Bool) in
            UIView.animateWithDuration(0.2) {
                self.gifIcon.hidden = false
            }
        }
        
    }
    
    func paramsTapResponse(recognizer: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.3) {
            self.lbsPickerContainer.hidden = false
            self.repsPickerContainer.hidden = false
            self.gifContainer.hidden = true
            self.gifIcon.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if pickerView == lbsPicker {
            return lbsRange.count
        }
        if pickerView == repsPicker {
            return repsRange.count
        }
        return 0
    }

    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView == lbsPicker {
            return String(lbsRange[item])
        }
        if pickerView == repsPicker {
            return String(repsRange[item])
        }
        return "?"
    }

    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        
        if pickerView == lbsPicker {
            Log.info(String(lbsRange[item]))
            lbsLabel.text = String(lbsRange[item])
        }
        if pickerView == repsPicker {
            Log.info(String(repsRange[item]))
            repsLabel.text = String(repsRange[item])
        }
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
