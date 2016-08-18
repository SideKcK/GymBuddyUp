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
    var greyText:UIColor
    var darkText: UIColor
    var contrastText: UIColor
    var navTint: UIColor
    var navBg: UIColor
    
    var calBg: UIColor
    var calText: UIColor
    var calTextDark: UIColor
    
    var buttonTint: UIColor
    
    var trackingNavigationButtonBg: UIColor
    var trackingNavigationButtonTx: UIColor
    var trackingNavigationParamsLabel: UIColor
    
    init (){
        bgGradientCenter = UIColor(red: 115/255.0, green: 220/255.0, blue: 227/255.0, alpha: 1.0)
        bgGradientOut = UIColor(red: 63/255.0, green: 203/255.0, blue: 213/255.0, alpha: 1.0)
        lightText = UIColor.whiteColor()
        greyText = UIColor.flatWhiteColorDark()
        darkText = ContrastColorOf(lightText, returnFlat: true)
        contrastText = ComplementaryFlatColorOf(bgGradientOut)
        navTint = UIColor.flatWhiteColor()
        navBg = UIColor.flatPlumColorDark()
        
        calBg = UIColor.flatPlumColorDark()
        calText = UIColor.flatWhiteColor()
        calTextDark = UIColor.flatWhiteColorDark()
        buttonTint = UIColor.flatMintColor()
        trackingNavigationButtonBg = UIColor.flatMintColor()
        trackingNavigationButtonTx = UIColor.flatWhiteColor()
        
        trackingNavigationParamsLabel = UIColor.flatBlackColor()
    }
}