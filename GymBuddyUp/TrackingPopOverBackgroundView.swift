//
//  TrackingPopOverBackgroundView.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TrackingPopOverBackgroundView: UIPopoverBackgroundView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override var arrowOffset: CGFloat {
        get {
            return 0.0
        }
        set {

        }
        
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return UIPopoverArrowDirection.Up
        }
        set {

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setup()
    }
    
    func setup() {

    }
    
    override class func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override class func arrowBase() -> CGFloat {
        return 2.0
    }
    
    override class func arrowHeight() -> CGFloat {
        return 2.0
    }
}
