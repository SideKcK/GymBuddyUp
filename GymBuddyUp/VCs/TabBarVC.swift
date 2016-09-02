//
//  TabBarVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController, UITabBarControllerDelegate {
    @IBOutlet weak var thisTabBar: UITabBar!
    let images = ["discover", "plan", "","inbox", "me"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.thisTabBar.translucent = false
        self.thisTabBar.tintColor = ColorScheme.s1Tint
        self.thisTabBar.barTintColor = ColorScheme.s4Bg
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)

        navigationBarAppearace.translucent = false
        navigationBarAppearace.tintColor = ColorScheme.g4Text  // Back buttons and such
        navigationBarAppearace.barTintColor = ColorScheme.s1Tint  // Bar's background color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:ColorScheme.g4Text]  // Title's text color
        
//        for parent in UINavigationBar().subviews {
//            for childView in parent.subviews {
//                if(childView is UIImageView) {
//                    childView.removeFromSuperview()
//                }
//            }
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var i = 0
        for item in thisTabBar.items! {
            if i != 2 {
                item.image  = UIImage(named: images[i])
            }
            i += 1
        }
        self.addCenterButtonWithImage(UIImage(named: "ActionButton")!, highlightImage: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addCenterButtonWithImage(buttonImage: UIImage, highlightImage: UIImage?){
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin]
        
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)
        button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        button.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
        button.addTarget(self, action: #selector(TabBarVC.buttonEvent), forControlEvents: UIControlEvents.TouchUpInside)
        
        let heightDifference: CGFloat = 0//buttonImage.size.height - self.tabBar.frame.size.height
        
        if (heightDifference < 0){
            button.center = self.tabBar.center
        }else{
            var center: CGPoint = self.tabBar.center
            center.y = center.y - self.tabBar.frame.origin.y - heightDifference/2.0
            button.center = center
        }
        
        //        self.view.addSubview(button)
        self.tabBar.addSubview(button)
        
    }
    
    func buttonEvent() {
        let storyboard = UIStoryboard(name: "Invitation", bundle: nil)
        
        let vc = storyboard.instantiateInitialViewController()
        self.presentViewController(vc!, animated: true, completion: nil)
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController.title == "Create" {
            return false
        }
        return true
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
