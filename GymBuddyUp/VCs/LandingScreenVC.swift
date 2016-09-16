//
//  LandingScreenVC.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import ChameleonFramework
import FBSDKLoginKit

class LandingScreenVC: UIViewController {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var loginWithFacebookButton: FBSDKLoginButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var loginButton: BorderedButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        logoView.tintColor = ColorScheme.p1Tint
        overlayView.backgroundColor = ColorScheme.s1Tint
        titleLabel.textColor = ColorScheme.g4Text
        infoLabel.textColor = ColorScheme.g4Text
        
        loginWithFacebookButton.makeRoundButton(ColorScheme.facebook)
        loginWithFacebookButton = FBSDKLoginButton()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    func addAlertView (button: UIButton, error: NSError) -> UIAlertController {
        let errorAlert = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: .Alert)
        errorAlert.customize()
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            button.enabled = true
            button.alpha = 1.0
        }
        
        errorAlert.addAction(OKAction)
        return errorAlert
    }

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSkipButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toMainSegue", sender: sender)
    }
    
    @IBAction func onLoginWithFacebookButton(sender: AnyObject) {

        User.signInWithFacebook(self){ (user, error) in
            if (error != nil) {
                // handle error here
                let alert = self.addAlertView(self.loginButton, error: error!)
                self.presentViewController(alert, animated: true, completion: nil)

            }
            else {
                self.performSegueWithIdentifier("toMainSegue", sender: sender)
            }
        }
    }
    
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    @IBAction func unwindToLandingVC(segue: UIStoryboardSegue) {
        
    }
}