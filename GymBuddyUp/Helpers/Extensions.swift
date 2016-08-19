//
//  Extensions.swift
//  GymBuddyUp
//
//  Created by you wu on 7/13/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CVCalendar
import HMSegmentedControl
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    func addShadow() {
        let lightColor = ColorScheme.sharedInstance.lightText
        let darkColor = ColorScheme.sharedInstance.darkText
        self.backgroundColor = lightColor
        self.layer.cornerRadius = 5
        self.layer.shadowColor = darkColor.CGColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 1
        //self.clipsToBounds = true
    }
    func addUnderline() {
        self.layer.shadowColor = ColorScheme.sharedInstance.darkText.CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 1
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

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image.CGImage else { return nil }
        self.init(CGImage: cgImage)
    }
    
    func resize(newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = self
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
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

extension UISegmentedControl
{
    func removeBorders() {
        setBackgroundImage(UIImage(color: backgroundColor!), forState: .Normal, barMetrics: .Default)
        setDividerImage(UIImage(color: tintColor), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)

    }
    
    func makeMultiline(numberOfLines: Int)
    {
        for segment in self.subviews
        {
            let labels = segment.subviews.filter { $0 is UILabel }	// [AnyObject]
            labels.map { ($0 as! UILabel).numberOfLines = numberOfLines }
        }
    }
}

extension HMSegmentedControl {
    func customize() {
        self.selectionIndicatorColor = ColorScheme.sharedInstance.buttonTint
        self.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        self.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed
        
        self.titleTextAttributes = [
            NSForegroundColorAttributeName: ColorScheme.sharedInstance.darkText,
            NSFontAttributeName: UIFont.systemFontOfSize(13)]
        self.backgroundColor = UIColor.clearColor()
        self.borderType = HMSegmentedControlBorderType.Bottom
        self.borderColor = ColorScheme.sharedInstance.greyText
        self.borderWidth = 1.5
        self.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
    }
}
struct DateRange : SequenceType {
    
    var calendar: NSCalendar
    var startDate: NSDate
    var endDate: NSDate
    var stepUnits: NSCalendarUnit
    var stepValue: Int
    
    func generate() -> Generator {
        return Generator(range: self)
    }
    
    struct Generator: GeneratorType {
        
        var range: DateRange
        
        mutating func next() -> NSDate? {
            let nextDate = range.calendar.dateByAddingUnit(range.stepUnits,
                                                           value: range.stepValue,
                                                           toDate: range.startDate,
                                                           options: NSCalendarOptions())
            if range.endDate < nextDate {
                return nil
            }
            else {
                range.startDate = nextDate!
                return nextDate
            }
        }
    }
}
