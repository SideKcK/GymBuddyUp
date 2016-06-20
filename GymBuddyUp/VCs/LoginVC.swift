//
//  LoginVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/15/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLoginButton(sender: AnyObject) {
        ServerAPI.sharedInstance.userLogin(usernameField.text!, password: passwordField.text!) { (error) in
            
        }
    }
}
