//
//  StatusView.swift
//  GymBuddyUp
//
//  Created by you wu on 9/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class StatusView: UIView {
    var view: UIView!
    
    /**
     Initialiser method
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        view = loadViewFromXibFile()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeBorderButton(ColorScheme.p1Tint)
        addSubview(view)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func loadViewFromXibFile() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "StatusView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    private func hideView() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0.0
        }) { (finished) -> Void in
            self.removeFromSuperview()
        }
    }
    
    func displayView(onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: onView, attribute: .Bottom, multiplier: 1.0, constant: 50.0)) // move it a bit upwards
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: onView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        onView.needsUpdateConstraints()
        
        // display the view
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1.0
        }) { (finished) -> Void in
            // When finished wait 1.5 seconds, than hide it
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.hideView()
            }
        }
    }
}
