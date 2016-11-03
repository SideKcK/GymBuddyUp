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

extension NSTimer {
    func safeInvalidate() {
        if valid {
           invalidate()
        }
    }
}

extension UIView {
    func addShadow() {
        let darkColor = ColorScheme.s2Shadow
        self.backgroundColor = ColorScheme.s4Bg
        self.layer.cornerRadius = 5
        self.layer.shadowColor = darkColor.CGColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1
        if let button = self as? UIButton {
            button.setTitleColor(ColorScheme.p1Tint, forState: .Normal)
        }
        //self.clipsToBounds = true
    }
    func makeBorderButton (color: UIColor) {
        self.layer.cornerRadius = self.frame.height / 2.0
        self.backgroundColor = ColorScheme.s4Bg
        self.tintColor = color
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
    }
    
    func makeBorderButton (color: UIColor, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.backgroundColor = ColorScheme.s4Bg
        self.tintColor = color
        
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
        
        if let button = self as? UIButton {
            button.setTitleColor(color, forState: .Normal)
        }
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, CGRectGetWidth(self.frame), thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        border.backgroundColor = color.CGColor;
        
        self.addSublayer(border)
    }
}

extension UIButton {
    func makeThumbnail(color: UIColor) {
        //self.backgroundColor = color
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = color.CGColor
        self.layer.cornerRadius = self.frame.height/2.0
        self.contentMode = UIViewContentMode.ScaleAspectFill
        self.clipsToBounds = true
    }

    func makeBotButton (color: UIColor? = ColorScheme.p1Tint) {
        self.heightAnchor.constraintEqualToConstant(44)
        self.backgroundColor = color
        self.setTitleColor(ColorScheme.g4Text, forState: .Normal)
        self.titleLabel?.font = UIFont.systemFontOfSize(20, weight: UIFontWeightMedium)
    }
    
    func makeActionButton () {
        self.layer.cornerRadius = 8
        self.heightAnchor.constraintEqualToConstant(44)
        self.backgroundColor = ColorScheme.p1Tint
        self.setTitleColor(ColorScheme.g4Text, forState: .Normal)
        self.tintColor = ColorScheme.g4Text
        self.titleLabel?.font = FontScheme.T1
    }
    
    func makeRoundButton (bgColor: UIColor? = ColorScheme.g3Text) {
        self.layer.cornerRadius = self.frame.height / 2.0
        self.clipsToBounds = true
        self.backgroundColor = bgColor
        self.setTitleColor(ColorScheme.g4Text, forState: .Normal)
        self.titleLabel?.font = FontScheme.T1
    }

}

extension UIView {
    func makeCircle(color: UIColor) {
        //self.backgroundColor = color
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = color.CGColor
        self.layer.cornerRadius = self.frame.height/2.0
        self.contentMode = UIViewContentMode.ScaleAspectFill
        self.clipsToBounds = true
    }
}

extension UIImageView {
    func makeThumbnail(color: UIColor) {
        //self.backgroundColor = color
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = color.CGColor
        self.layer.cornerRadius = self.frame.height/2.0
        self.contentMode = UIViewContentMode.ScaleAspectFill
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
    
//    func resize(newSize: CGSize) -> UIImage {
//        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
//        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
//        resizeImageView.image = self
//        
//        UIGraphicsBeginImageContext(resizeImageView.frame.size)
//        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//    }
}

extension UIAlertController {
    func customize() {
        let backView = self.view.subviews.last?.subviews.last
        //backView?.layer.cornerRadius = 10.0
        backView?.alpha = 1.0
        self.view.tintColor = ColorScheme.p1Tint
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

extension NSDate {
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> NSDate {
        let timezone: NSTimeZone = NSTimeZone.localTimeZone()
        let seconds: NSTimeInterval = NSTimeInterval(timezone.secondsFromGMTForDate(self))
        return NSDate(timeInterval: seconds, sinceDate: self)
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> NSDate {
        let timezone: NSTimeZone = NSTimeZone.localTimeZone()
        let seconds: NSTimeInterval = -NSTimeInterval(timezone.secondsFromGMTForDate(self))
        return NSDate(timeInterval: seconds, sinceDate: self)
    }
}

extension NSDate {
    class func changeDaysBy(days : Int) -> NSDate {
        let currentDate = NSDate()
        let dateComponents = NSDateComponents()
        dateComponents.day = days
        return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
    }
    
    class func timeAgoSinceDate(date: NSDate, numericDates: Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.year >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d years ago", comment: ""), components.year)
        } else if (components.year >= 1){
            if (numericDates){
                return NSLocalizedString("1 year ago", comment: "")
            } else {
                return NSLocalizedString("Last year", comment: "")
            }
        } else if (components.month >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d months ago", comment: ""), components.month)
        } else if (components.month >= 1){
            if (numericDates){
                return NSLocalizedString("1 month ago", comment: "")
            } else {
                return NSLocalizedString("Last month", comment: "")
            }
        } else if (components.weekOfYear >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d weeks ago", comment: ""), components.weekOfYear)
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return NSLocalizedString("1 week ago", comment: "")
            } else {
                return NSLocalizedString("Last week", comment: "")
            }
        } else if (components.day >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d days ago", comment: ""), components.day)
        } else if (components.day >= 1){
            if (numericDates){
                return NSLocalizedString("1 day ago", comment: "")
            } else {
                return NSLocalizedString("Yesterday", comment: "")
            }
        } else if (components.hour >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d hours ago", comment: ""), components.hour)
        } else if (components.hour >= 1){
            if (numericDates){
                return NSLocalizedString("1 hours ago", comment: "")
            } else {
                return NSLocalizedString("An hour ago", comment: "")
            }
        } else if (components.minute >= 2) {
            return String.localizedStringWithFormat(NSLocalizedString("%d minutes ago", comment: ""), components.minute)
        } else if (components.minute >= 1){
            if (numericDates){
                return NSLocalizedString("1 minute ago", comment: "")
            } else {
                return NSLocalizedString("A minute ago", comment: "")
            }
        } else if (components.second >= 3) {
            return String.localizedStringWithFormat(NSLocalizedString("%d seconds ago", comment: ""), components.second)
        } else {
            return NSLocalizedString("Just now", comment: "")
        }
    }
}

extension UISegmentedControl
{
    func removeBorders() {
        setBackgroundImage(UIImage(color: backgroundColor!), forState: .Normal, barMetrics: .Default)
        setDividerImage(UIImage(color: tintColor), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)

    }
}

extension HMSegmentedControl {
    func customize() {
        self.selectionIndicatorHeight = 2.0
        self.selectionIndicatorColor = ColorScheme.p1Tint
        self.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        self.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed
        
        self.titleTextAttributes = [
            NSForegroundColorAttributeName: ColorScheme.g3Text,
            NSFontAttributeName: FontScheme.T2 ]
        self.selectedTitleTextAttributes = [
        NSForegroundColorAttributeName: ColorScheme.p1Tint]
        self.backgroundColor = UIColor.clearColor()
        self.borderType = HMSegmentedControlBorderType.Bottom
        self.borderColor = ColorScheme.g3Text
        self.borderWidth = 1
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

extension UIView {
    func setBottomBorder(color color: UIColor) -> UIView {
        let BottomBorder = UIView()
        BottomBorder.frame = CGRectMake(0.0, self.frame.size.height - 1, self.frame.size.width, 1.0)
        BottomBorder.backgroundColor = color
        self.addSubview(BottomBorder)
        return BottomBorder
    }
    
    func setBottomBorderCA(color color: UIColor) -> CALayer {
        let BottomBorder = CALayer()
        BottomBorder.frame = CGRectMake(0.0, self.frame.size.height - 1, self.frame.size.width, 1.0)
        BottomBorder.backgroundColor = color.CGColor
        self.layer.addSublayer(BottomBorder)
        return BottomBorder
    }
    
    func applyPlainShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 1.3, height: 1.3)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 1
        
    }
    
    func applySharpShadow(color: UIColor) {
        layer.shadowColor = color.CGColor
        layer.shadowOffset = CGSize(width: 1.3, height: 1.3)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 0.2
    }
}

extension UITextField {
    func signuploginFieldStyle() {
        font = FontScheme.T1
        
    }
}

extension Array {
    func reverseIndex(index: Int) -> Int {
        return count - index - 1
    }
    
    func reverseGet(index: Int) -> Element {
        return self[reverseIndex(index)]
    }
}
