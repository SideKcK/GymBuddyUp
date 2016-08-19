//
//  Utils.swift
//  GymBuddyUp
//
//  Created by you wu on 5/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

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

func dateTimeFormatter () -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
    
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    
    return dateFormatter
}