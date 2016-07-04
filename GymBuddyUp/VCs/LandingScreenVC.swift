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
import FBSDKLoginKit

class LandingScreenVC: UIViewController {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var loginWithFacebookButton: FBSDKLoginButton!
    @IBOutlet weak var signUpButton: BorderedButton!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlayView.backgroundColor = GradientColor(.Radial, frame: overlayView.bounds, colors: [ColorScheme.sharedInstance.bgGradientCenter, ColorScheme.sharedInstance.bgGradientOut])
        titleLabel.textColor = ColorScheme.sharedInstance.lightText
        infoLabel.textColor = ColorScheme.sharedInstance.lightText
        
        loginWithFacebookButton = FBSDKLoginButton()
        
        // facebook login related
        // Set current token to nil so that fb login view will always present. WuYou: Remove this line if you no longer need to test login view.
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        if (FBSDKAccessToken.currentAccessToken() != nil) // TODO: replace with firebase auth check
        {
            // User is already logged in, do work such as go to next view controller.
            print("already logged in")
            self.performSegueWithIdentifier("toMainSegue", sender: nil)
            
        }

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(sender: AnyObject) {
        //testing
        self.performSegueWithIdentifier("toMainSegue", sender: sender)
        
        /*
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
         */
    }
    
    @IBAction func onLoginWithFacebookButton(sender: AnyObject) {
        print("Login button tapped")
        
        let loginManager = FBSDKLoginManager()
        
        let facebookReadPermissions = ["public_profile", "email"]
        loginManager.logInWithReadPermissions(facebookReadPermissions, fromViewController: self, handler: { (result, error) in
            if error != nil {
                print("FBLogin failed")
                print(error.localizedDescription);
            } else if(result.isCancelled) {
                print("FBLogin cancelled")
            } else {
                print(result.grantedPermissions)
                print(result.token.tokenString)
                
                // [START headless_facebook_auth]
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                // [END headless_facebook_auth]
               FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                if let error = error {
                    print("FB Sign in error")
                    print(error.localizedDescription);
                }
                else {
                    print(user?.displayName);
                    print(user?.photoURL);
                    print(user?.providerID);
                    print(user?.getTokenWithCompletion({ (tokenString, err) in
                        print(tokenString);
                    }))
                    self.performSegueWithIdentifier("toMainSegue", sender: sender)
                }
               })
            }
        })
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
