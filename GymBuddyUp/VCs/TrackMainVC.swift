//
//  TrackMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/1/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TrackMainVC: UIViewController, AKPickerViewDelegate, AKPickerViewDataSource, UIPopoverPresentationControllerDelegate, DropDownTitleNavButtonDelegate {
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var botButton: UIButton!
    
    @IBOutlet weak var progressIndicatorLabel: UILabel!
    @IBOutlet weak var lbsPicker: AKPickerView!
    
    @IBOutlet weak var repsPicker: AKPickerView!
    
    @IBOutlet weak var lbsLabel: KKParamsLabel!
    @IBOutlet weak var repsLabel: KKParamsLabel!

    @IBOutlet weak var lbsPickerContainer: UIView!
    @IBOutlet weak var repsPickerContainer: UIView!
    @IBOutlet weak var gifContainer: UIView!
    @IBOutlet weak var timerContainer: UIView!
    @IBOutlet weak var paramsContainer: UIView!
    @IBOutlet weak var gifIcon: UIButton!
    
    @IBOutlet weak var exerciseLabel: UILabel!
    
    
    
    var trackedPlan: TrackedPlan?
    var seconds: Float = 0.0
    var secondTotal: Float = 0.0
    var timer = NSTimer()
    var currentTrackedIndex = 0
    var popoverVC: UIViewController?
    var itemsCount = 0
    
    var finishedSets = 0 {
        didSet {
            guard let _currentUnitType = trackedPlan?.trackingItems[currentTrackedIndex].exercise?.unitType else {return}
            Log.info("\(_currentUnitType)")

            guard let _currentTrackedItem =  trackedPlan?.trackingItems[currentTrackedIndex] else {return}
            if (_currentUnitType == Exercise.UnitType.Repetition) || (_currentUnitType == Exercise.UnitType.RepByWeight) {
                Log.info("finishedSets for Rep and RepByWeight")
                progressIndicatorLabel.text = "\(finishedSets + 1) SET"
                progressLabel.text = "\(finishedSets)/\(_currentTrackedItem.setsAmount)"
                let progressValue = (Float(finishedSets))/(Float(_currentTrackedItem.setsAmount))
                    progressView.setProgress(progressValue, animated: false)
            }
        }
    }
    
    var finishedAmount = 0 {
        didSet {
            guard let _currentUnitType = trackedPlan?.trackingItems[currentTrackedIndex].exercise?.unitType else {return}
            Log.info("\(_currentUnitType)")
            guard let _currentTrackedItem =  trackedPlan?.trackingItems[currentTrackedIndex] else {return}
            if !((_currentUnitType == Exercise.UnitType.Repetition) || (_currentUnitType == Exercise.UnitType.RepByWeight)) {
                if let amount = _currentTrackedItem.exercise?.set[0]?.amount {
                    Log.info("finishedAmount for Rep and RepByWeight")
                    progressLabel.text = secondsToHoursMinutesSeconds(amount)
                    timerLabel.text = secondToString(Float(finishedAmount))
                    let progressValue = (Float(finishedAmount))/(Float(amount))
                    progressView.setProgress(progressValue, animated: true)
                }
            }
        }
    }
    var currentUnitType: Exercise.UnitType?
    
    var repsRange = [1, 2, 3, 4, 5, 6, 7, 8]
    var lbsRange = [10, 15, 20, 25, 30, 35, 40]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        Log.info("trackingItems in TrackMainVC \(trackedPlan?.trackingItems.count)")
        
        if let _count = trackedPlan?.trackingItems.count {
            itemsCount += _count
        }
        
        Log.info("itemsCount \(itemsCount)")
        
        loadTrackingItem()
        
        // init popoverVC
        popoverVC = storyboard!.instantiateViewControllerWithIdentifier("trackingTodo")
        popoverVC?.modalPresentationStyle = .Popover
        
        let dropDownTitleNavButton = DropDownTitleNavButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        Log.info("\(currentTrackedIndex + 1)/\(itemsCount)")
        dropDownTitleNavButton.title = "\(currentTrackedIndex + 1)/\(itemsCount)"
        dropDownTitleNavButton.delegate = self
        self.navigationItem.titleView = dropDownTitleNavButton
        
        // Do any additional setup after loading the view.
    }
    
    func exerciseContextSave(onFinishedAmount: Int, onFinishedSets: Int) {
        // save current context
        if let currentTrackedItem =  trackedPlan?.trackingItems[currentTrackedIndex] {
            currentTrackedItem.saveOnNextExercise(finishedAmount, onFinishedSets: finishedSets)
        }
        
        loadTrackingItem()
    }
    
    @IBAction func previousItemOnClick(sender: AnyObject) {
        if currentTrackedIndex > 0 {
            currentTrackedIndex -= 1
            exerciseContextSave(finishedAmount, onFinishedSets: finishedSets)
        }
    }
    

    @IBAction func nextItemOnClick(sender: AnyObject) {
        if currentTrackedIndex < itemsCount - 1 {
            currentTrackedIndex += 1
            exerciseContextSave(finishedAmount, onFinishedSets: finishedSets)
        }
    }
    
    
    
    @IBAction func bottomButtonOnClick(sender: AnyObject) {
        guard let _currentUnitType = self.currentUnitType, currentTrackedItem =  trackedPlan?.trackingItems[currentTrackedIndex] else {return}
        if (_currentUnitType == Exercise.UnitType.Repetition) || (_currentUnitType == Exercise.UnitType.RepByWeight) {
            // save current context
            guard let reps = repsLabel.text, weight = lbsLabel.text else {return}
            guard let repsValue = Int(reps), weightValue = Int(weight) else {return}
            currentTrackedItem.saveOnNextSet(repsValue, weight: weightValue)
            if currentTrackedItem.finishedSets == currentTrackedItem.setsAmount {
                exerciseContextSave(finishedAmount, onFinishedSets: finishedSets)
            }
        } else {
            
        
        }
    }
    
    
    func loadTrackingItem() {
        
        // reset context
        finishedSets = 0
        finishedAmount = 0
        
        // reload views needed
        lbsPickerContainer.hidden = true
        repsPickerContainer.hidden = true
        gifContainer.hidden = false
        gifIcon.hidden = false
        
        guard let _currentUnitType = trackedPlan?.trackingItems[currentTrackedIndex].exercise?.unitType else {return}
        guard let _currentTrackedItem =  trackedPlan?.trackingItems[currentTrackedIndex] else {return}
        currentUnitType = _currentUnitType

        if (_currentUnitType == Exercise.UnitType.Repetition) || (_currentUnitType == Exercise.UnitType.RepByWeight) {
            timerContainer.hidden = true
            paramsContainer.hidden = false
        } else {
            timerContainer.hidden = false
            paramsContainer.hidden = true
        }
        
        
        if let _currentExpectedAmount = trackedPlan?.trackingItems[currentTrackedIndex].exercise?.set[0]?.amount {
            Log.info(String(_currentExpectedAmount))
        }
        
        if let _currentExerciseName = trackedPlan?.trackingItems[currentTrackedIndex].exercise?.name {
            exerciseLabel.text = _currentExerciseName
        }
        
        // reload progress
        
        
    }
    
    func dropDownTitleNavButton(button: DropDownTitleNavButton) {
        if let _popoverVC = popoverVC {
            if let popoverController = _popoverVC.popoverPresentationController {
                let desVC = _popoverVC as! TrackingPopOverViewController
                desVC.trackedPlan = trackedPlan
                var itemCount: CGFloat = 0.0
                if let _itemCount = trackedPlan?.trackingItems.count {
                    itemCount = 0
                    itemCount += CGFloat(_itemCount)
                }
                desVC.preferredContentSize =  CGSizeMake(320, itemCount * 55)
                popoverController.sourceView = button
                popoverController.sourceRect = button.bounds
                popoverController.permittedArrowDirections = .Up
                popoverController.delegate = self
                presentViewController(_popoverVC, animated: true, completion: nil)
            }
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
        secondTotal = seconds
        progressView.setProgress(1.0, animated: true)
        progressLabel.text = secondToMin(secondTotal)
        timerLabel.text = secondToString(seconds)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(TrackMainVC.addTime), userInfo: nil, repeats: true)
    }

    func addTime() {
        guard let _currentTrackedItem =  trackedPlan?.trackingItems[currentTrackedIndex] else {return}
        guard let currentExercise = _currentTrackedItem.exercise else {return}
        finishedAmount += 1
        if(finishedAmount == currentExercise.set[0]?.amount)  {
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

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//    }

}
