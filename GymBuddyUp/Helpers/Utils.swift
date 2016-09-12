//
//  Utils.swift
//  GymBuddyUp
//
//  Created by you wu on 5/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

func resize(image: UIImage, newSize: CGSize) -> UIImage {
    let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
    resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
    resizeImageView.image = image
    
    UIGraphicsBeginImageContext(resizeImageView.frame.size)
    resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

class Log {
    /* A simple logger written by Yi Huang */
    class func info(content: String?) {
        if let content = content {
            print("[Log][INFO]: \(content)")
        } else {
            print("[Log][INFO]: nil")
        }
    }
    
    class func error(content: String?) {
        if let content = content {
            print("[Log][ERROR]: \(content)")
        } else {
            print("[Log][ERROR]: nil")
        }
    }
    
    class func warning(content: String?) {
        if let content = content {
            print("[Log][WARN]: \(content)")
        } else {
            print("[Log][WARN]: nil")
        }
    }
}


func secondToString(sec: Float) -> String {
    let hours = Int(sec) / 3600
    let minutes = Int(sec) / 60 % 60
    let seconds = Int(sec) % 60
    return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
}

func secondToMin(sec: Float) -> String {
    let minutes = Int(sec) / 60 % 60
    return String(minutes)+" mins"
}

func secondsToHoursMinutesSeconds (seconds : Int) -> String {
    let secs = (seconds % 3600) % 60
    var secsString = String(secs)
    if secsString.characters.count == 1 {
        secsString = "0\(secsString)"
    }
    return "\((seconds % (3600 * 24)) / 60):\(secsString)"
}

func dateTimeFormatter () -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    
    return dateFormatter
}


func weekMonthDateString (date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "EEE, MMM d"
    if date.isInToday() {
        return "Today"
    }else if date.isInTomorrow() {
        return "Tomorrow"
    }else {
        return dateFormatter.stringFromDate(date)
    }
}

func timeString (date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    return dateFormatter.stringFromDate(date)
}