//
//  UnderlineField.swift
//  GymBuddyUp
//
//  Created by you wu on 8/1/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class UnderlineField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let textColor = ColorScheme.sharedInstance.lightText
        self.textColor = textColor
        if let placeholder = self.placeholder {
        self.attributedPlaceholder = NSAttributedString(string:placeholder,attributes: [NSForegroundColorAttributeName: textColor])
        }
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = textColor.CGColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
    }

}
