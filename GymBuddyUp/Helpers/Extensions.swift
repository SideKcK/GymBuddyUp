//
//  Extensions.swift
//  GymBuddyUp
//
//  Created by you wu on 7/13/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CVCalendar

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImageView {
    func makeThumbnail() {
        self.backgroundColor = UIColor.flatGrayColor()
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.flatGrayColor().CGColor
        self.layer.cornerRadius = self.frame.height/2.0
        self.clipsToBounds = true
    }
}

extension CVDate {
    public var monthDescription: String {
        get {
            var month = globalDescription
            if let dotRange = month.rangeOfString(",") {
                month.removeRange(dotRange.startIndex..<month.endIndex)
            }
            return month
        }
    }
}
