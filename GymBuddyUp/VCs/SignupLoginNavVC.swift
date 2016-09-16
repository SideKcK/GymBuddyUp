//
//  SignupLoginNavVC.swift
//  GymBuddyUp
//
//  Created by you wu on 5/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class SignupLoginNavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        navigationBarAppearace.translucent = false
        navigationBarAppearace.tintColor = ColorScheme.g4Text  // Back buttons and such
        navigationBarAppearace.barTintColor = ColorScheme.s1Tint  // Bar's background color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:ColorScheme.g4Text]  // Title's text color

        
//        self.navigationBar.backgroundColor = ColorScheme.s1Tint
//        self.navigationBar.shadowImage = UIImage()
//        self.navigationBar.tintColor = ColorScheme.g4Text
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : ColorScheme.g4Text]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
