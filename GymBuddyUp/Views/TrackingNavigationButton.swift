//
//  TrackingNavigationButton.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/17/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TrackingNavigationButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        // because storyboard has intrinsic width (4s for inferred size), when this view shows on bigger screen, we need to update bounds as well (Maybe it's a bug??)
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.backgroundColor = ColorScheme.sharedInstance.trackingNavigationButtonBg.CGColor
        self.tintColor = ColorScheme.sharedInstance.trackingNavigationButtonTx
//        self.titleLabel?.font = UIFont(name: "Helvetica Neue-Condensed Bold", size: self.frame.height * 0.65)
    }

}
