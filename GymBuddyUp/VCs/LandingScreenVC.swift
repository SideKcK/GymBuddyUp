//
//  LandingScreenVC.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase

class LandingScreenVC: UIViewController {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var signUpButton: BorderedButton!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
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
    
    @IBAction func onLoginButton(sender: AnyObject) {
        //check if username valid
        //        ServerAPI.sharedInstance.userLogin(usernameField.text!, password: passwordField.text!) { (error) in
        //            if error == nil {
        //                self.performSegueWithIdentifier("toMainSegue", sender: sender)
        //            }else {
        //                let alert = UIAlertController(title: "Login Failed", message: error?.message, preferredStyle: .Alert)
        //                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        //                alert.addAction(OKAction)
        //                self.presentViewController(alert, animated: true, completion: nil)
        //                return
        //            }
        //        }
        
        FIRAuth.auth()?.signInWithEmail(usernameField.text!, password: passwordField.text!) { (user, error) in
            // ...
            
            if error == nil {
                self.performSegueWithIdentifier("toMainSegue", sender: sender)
                
                
                
            }else {
                let alert = UIAlertController(title: "Login Failed", message: error?.description, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(OKAction)
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    @IBAction func unwindToLandingVC(segue: UIStoryboardSegue) {
        
    }
    
}
