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
        self.layer.cornerRadius = 10
        self.backgroundColor = ColorScheme.s4Bg
        self.tintColor = color
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
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
    func makeBotButton () {
        self.heightAnchor.constraintEqualToConstant(44)
        self.backgroundColor = ColorScheme.p1Tint
        self.setTitleColor(ColorScheme.g4Text, forState: .Normal)
        self.titleLabel?.font = UIFont.systemFontOfSize(20, weight: UIFontWeightMedium)
    }
    
    func makeActionButton () {
        self.layer.cornerRadius = 8
        self.heightAnchor.constraintEqualToConstant(44)
        self.backgroundColor = ColorScheme.p1Tint
        self.setTitleColor(ColorScheme.g4Text, forState: .Normal)
        self.tintColor = ColorScheme.g4Text
        self.titleLabel?.font = FontScheme.T2
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
        self.selectionIndicatorColor = ColorScheme.p1Tint
        self.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
        self.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed
        
        self.titleTextAttributes = [
            NSForegroundColorAttributeName: ColorScheme.g3Text,
            NSFontAttributeName: FontScheme.T2 ]
        self.backgroundColor = UIColor.clearColor()
        self.borderType = HMSegmentedControlBorderType.Bottom
        self.borderColor = ColorScheme.greyText
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
    
    func setTopBorder(color color: UIColor) {
        let TopBorder = CALayer()
        TopBorder.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 1.5)
        TopBorder.backgroundColor = color.CGColor
        TopBorder.opacity = 0.3
        
        self.layer.addSublayer(TopBorder)
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
