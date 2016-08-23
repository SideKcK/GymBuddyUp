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

struct ColorScheme {
    //final colors
    static var p1Tint = UIColor(hexString: "00D5A0")
    static var s1Tint = UIColor(hexString: "3A2B51")
    static var s2Shadow = UIColor(hexString: "DCDADD")
    static var s3Bg = UIColor(hexString: "F5F3F7")
    static var s4Bg = UIColor.whiteColor()
    static var e1Tint = UIColor(hexString: "EB4B40")
    static var g1Text = UIColor(hexString: "000000")
    static var g2Text = UIColor(hexString: "6F6F6F")
    static var g3Text = UIColor(hexString: "BBBBBB")
    static var g4Text = ContrastColorOf(s1Tint, returnFlat: false)
    
    //to be deprecated
    //to be deprecated
    static var bgGradientCenter = UIColor(red: 115/255.0, green: 220/255.0, blue: 227/255.0, alpha: 1.0)
    static var bgGradientOut = UIColor(red: 63/255.0, green: 203/255.0, blue: 213/255.0, alpha: 1.0)
    static var greyText = UIColor.flatWhiteColorDark()
    //darkText = ContrastColorOf(lightText, returnFlat: true)
    static var contrastText = ComplementaryFlatColorOf(bgGradientOut)

    static var trackingNavigationButtonBg = UIColor.flatMintColor()
    static var trackingNavigationButtonTx = UIColor.flatWhiteColor()
    
    static var trackingNavigationParamsLabel = UIColor.flatBlackColor()
    static var trackingDoneModalBg = UIColor ( red: 0.08, green: 0.0, blue: 0.0, alpha: 0.68 )
    
}