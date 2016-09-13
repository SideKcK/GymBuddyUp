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
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var nextButton: BorderedButton!
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var alertController: UIAlertController!
    var profileImage: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        profileImage = UIImage(named: "dumbbell")
        
        self.view.backgroundColor = GradientColor(.Radial, frame: self.view.bounds, colors: [ColorScheme.bgGradientCenter, ColorScheme.bgGradientOut])
        let textColor = ColorScheme.g4Text
        loginLabel.textColor = textColor
        loginButton.titleLabel?.textColor = ColorScheme.contrastText
        setTextField(emailField)
        setTextField(passwordField)
        setTextField(usernameField)
        setTextField(confirmField)
        //nextButton.enabled = true

        //alert controller
        alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        alertController.customize()
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.nextButton.enabled = true
            self.nextButton.alpha = 1.0
        }
        alertController.addAction(OKAction)
        
    }
    
    func setTextField(textField: UITextField) {
        textField.layer.masksToBounds = true
        textField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onProfileButton(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self

        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func onNextButton(sender: AnyObject) {
        nextButton.enabled = false
        nextButton.alpha = 0.3
        
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
                    User.signUpWithEmail(emailField.text!, password: confirmField.text!) { (user, error) in
                        if let user = user {                            
                            //upload photo
                            
                            user.updateProfilePicture(self.profileImage){error in
                                print("Error setting profile picture \(error?.localizedFailureReason)")
                            }
                            //update screen name
                            user.updateProfile("screenName", value: self.usernameField.text)
                            self.performSegueWithIdentifier("toGenderSegue", sender: self)
                        }else {
                            print(error)
                        }
                    }
                
                }else {
                    
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
extension SignupVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        profileImage = editedImage.imageScaledToSize(CGSizeMake(500, 500))
        profileButton.setImage(profileImage.imageScaledToSize(CGSizeMake(50, 50)), forState: .Normal)
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension SignupVC:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
