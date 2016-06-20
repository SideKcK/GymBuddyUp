//
//  LandingScreenVC.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import ChameleonFramework

class LandingScreenVC: UIViewController {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var signUpButton: BorderedButton!
    @IBOutlet weak var loginButton: BorderedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayView.backgroundColor = GradientColor(.Radial, frame: overlayView.bounds, colors: [ColorScheme.sharedInstance.bgGradientCenter, ColorScheme.sharedInstance.bgGradientOut])
        titleLabel.textColor = ColorScheme.sharedInstance.lightText
        infoLabel.textColor = ColorScheme.sharedInstance.lightText

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
