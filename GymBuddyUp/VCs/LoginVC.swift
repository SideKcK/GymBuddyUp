//
//  LoginVC.swift
//  GymBuddyUp
//
//  Created by you wu on 9/15/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import KRProgressHUD
class LoginVC: UIViewController {
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var forgetLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        setupVisual()
        usernameField.delegate = self
        passwordField.delegate = self
        errorLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupVisual() {
        logoView.tintColor = ColorScheme.p1Tint
        self.view.backgroundColor = ColorScheme.s3Bg
        
        errorLabel.textColor = ColorScheme.e1Tint
        errorLabel.font = FontScheme.T3
        
        loginButton.makeRoundButton()
        loginButton.enabled = false
        forgetLabel.textColor = ColorScheme.g3Text
        forgetLabel.font = FontScheme.T3
        resetButton.setTitleColor(ColorScheme.p1Tint, forState: .Normal)
        resetButton.titleLabel?.font = FontScheme.T1
        
    }
    @IBAction func onEditDidEnd(sender: AnyObject) {
        if !usernameField.text!.isEmpty &&
            !passwordField.text!.isEmpty {
            loginButton.enabled = true
            loginButton.backgroundColor = ColorScheme.p1Tint
        }
    }
    
    @IBAction func onLoginButton(sender: AnyObject) {
        loginButton.enabled = false
        loginButton.alpha = 0.3
        KRProgressHUD.show()
        User.signInWithEmail(usernameField.text!, password: passwordField.text!) { (user, error) in
            if (error != nil){
                // handle error here
                self.errorLabel.text =  error!.localizedDescription
                KRProgressHUD.showError()
                self.loginButton.enabled = true
                self.loginButton.alpha = 1.0
            }
            else {
                KRProgressHUD.dismiss()
                self.performSegueWithIdentifier("toMainSegue", sender: sender)
            }
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

extension LoginVC : UITextFieldDelegate {
    
}