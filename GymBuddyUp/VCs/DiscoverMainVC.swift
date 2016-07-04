//
//  DiscoverMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class DiscoverMainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let segment: UISegmentedControl = UISegmentedControl(items: ["All", "Friends"])
        segment.sizeToFit()
        segment.tintColor = UIColor.flatSkyBlueColor()
        segment.selectedSegmentIndex = 0
        self.navigationItem.titleView = segment
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
