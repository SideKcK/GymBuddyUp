//
//  BorderedButton.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel?.textColor = ColorScheme.sharedInstance.lightText
        backgroundColor = UIColor.clearColor()
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = titleLabel?.textColor.CGColor

    }
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                backgroundColor = ColorScheme.sharedInstance.lightText

            } else {
                backgroundColor = UIColor.clearColor()
            }
        }
    }
}
