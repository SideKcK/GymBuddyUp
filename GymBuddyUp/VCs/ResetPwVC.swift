//
//  ResetPwVC.swift
//  GymBuddyUp
//
//  Created by you wu on 9/15/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class ResetPwVC: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var searchButton: UIBarButtonItem!

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisual()
        emailField.delegate = self
        self.hideKeyboardWhenTappedAround()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupVisual() {
        self.view.backgroundColor = ColorScheme.s3Bg
        nextButton.makeRoundButton()
        nextButton.enabled = false
        resendButton.titleLabel?.font = FontScheme.T2
        resendButton.setTitleColor(ColorScheme.p1Tint, forState: .Normal)
        infoView.hidden = true
        infoLabel.hidden = true
    }

    @IBAction func onSearchButton(sender: AnyObject) {
        //check email
        if let email = emailField.text {
            if Validation.isValidEmail(email) {
                //found email
                emailField.layer.borderColor = ColorScheme.p1Tint.CGColor
                emailField.layer.borderWidth = 1.0
                statusLabel.text = "We found your account"
                searchButton.enabled = false
                searchButton.tintColor = UIColor.clearColor()
                nextButton.enabled = true
                nextButton.backgroundColor = ColorScheme.p1Tint
            }else {
                statusLabel.text = "We couldn't find your account"
                statusLabel.textColor = ColorScheme.e1Tint
                emailField.layer.borderColor = ColorScheme.e1Tint.CGColor
                emailField.layer.borderWidth = 1.0
            }
        }
    }
    
    @IBAction func onNextButton(sender: AnyObject) {
        //send reset password request
        nextButton.enabled = false
        nextButton.backgroundColor = ColorScheme.g3Text
        nextButton.setTitle("Email sent", forState: .Normal)
        infoLabel.hidden = false
        infoView.hidden = false
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

extension ResetPwVC : UITextFieldDelegate {
    
}