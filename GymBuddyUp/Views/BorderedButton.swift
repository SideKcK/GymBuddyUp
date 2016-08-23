//
//  BorderedButton.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {
    var textColor = ColorScheme.g4Text
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        titleLabel?.textColor = textColor
        backgroundColor = UIColor.clearColor()
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = titleLabel?.textColor.CGColor
        
    }
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                backgroundColor = textColor

            } else {
                backgroundColor = UIColor.clearColor()
            }
        }
    }
    override var selected: Bool {
        didSet {
            if selected {
                backgroundColor = textColor
            }else {
                backgroundColor = UIColor.clearColor()
            }
        }
    }
}
