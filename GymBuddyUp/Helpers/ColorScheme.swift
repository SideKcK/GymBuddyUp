//
//  ColorScheme.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import Foundation
import ChameleonFramework
import UIKit

class ColorScheme {
    static var sharedInstance = ColorScheme()
    var bgGradientCenter: UIColor
    var bgGradientOut: UIColor
    var lightText:UIColor
    var darkText: UIColor
    var contrastText: UIColor
    
    init (){
        bgGradientCenter = UIColor(red: 115/255.0, green: 220/255.0, blue: 227/255.0, alpha: 1.0)
        bgGradientOut = UIColor(red: 63/255.0, green: 203/255.0, blue: 213/255.0, alpha: 1.0)
        lightText = ContrastColorOf(FlatBlack(), returnFlat: true)
        darkText = ContrastColorOf(FlatWhite(), returnFlat: true)
        contrastText = ComplementaryFlatColorOf(bgGradientOut)
        }
}