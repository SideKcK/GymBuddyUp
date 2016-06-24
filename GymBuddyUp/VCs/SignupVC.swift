//
//  SignupVC.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import ChameleonFramework

class SignupVC: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!

    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    var alertController: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = GradientColor(.Radial, frame: self.view.bounds, colors: [ColorScheme.sharedInstance.bgGradientCenter, ColorScheme.sharedInstance.bgGradientOut])
        let textColor = ColorScheme.sharedInstance.lightText
        loginLabel.textColor = textColor
        loginButton.titleLabel?.textColor = ColorScheme.sharedInstance.contrastText
        setTextField(emailField)
        setTextField(passwordField)
        setTextField(usernameField)
        setTextField(confirmField)
        
        //alert controller
        alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)

    }
    
    func setTextField(textField: UITextField) {
        let textColor = ColorScheme.sharedInstance.lightText
        textField.textColor = textColor
        textField.attributedPlaceholder = NSAttributedString(string:textField.placeholder!,attributes: [NSForegroundColorAttributeName: textColor])
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = textColor.CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
        textField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(false)

    }
    
    @IBAction func onNextButton(sender: AnyObject) {
        //check validation
        if emailField.text!.isEmpty || passwordField.text!.isEmpty || usernameField.text!.isEmpty || confirmField.text!.isEmpty{
            alertController.title = "Sign Up Failed"
            alertController.message = "All fields must be entered."
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if Validation.isValidEmail(emailField.text!) {
            if Validation.isPasswordSame(passwordField.text!, confirmPassword: confirmField.text!) {
                let pwStatus = Validation.isValidPassword(passwordField.text!)
                if  pwStatus == .succeed {
                        ServerAPI.sharedInstance.userSignUp(usernameField.text, email: emailField.text, password: passwordField.text, completion: { (user, error) in
                            if error == nil {
                            print("Sign Up Succeed")
                            //send activate email
                            self.performSegueWithIdentifier("toGenderSegue", sender: self)
                            }
                        })
                    

                }else{
                    alertController.title = "Sign Up Failed"
                    if pwStatus == .countError {
                    alertController.message = "Your password must be 5-20 charaters."
                    }else {
                        alertController.message = "Your password must contain both digits and letters."
                    }
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
            }else {
                alertController.title = "Sign Up Failed"
                alertController.message = "Please confirm password."
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
        }else {
            alertController.title = "Sign Up Failed"
            alertController.message = "Invalid Email."
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignupVC:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}