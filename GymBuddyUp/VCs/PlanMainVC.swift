//
//  PlanMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanMainVC: UIViewController {
    @IBOutlet weak var calCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        calCollectionView.dataSource = self
        calCollectionView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToPlanMainVC(segue: UIStoryboardSegue) {
        
    }
    @IBAction func onNewPlanButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "New Plan", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let BuildAction = UIAlertAction(title: "Build your own", style: .Default) { (action) in
            self.performSegueWithIdentifier("toBuildPlanSegue", sender: self)
        }
        alertController.addAction(BuildAction)
        
        let LibAction = UIAlertAction(title: "SicdKck training library", style: .Default) { (action) in
            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        }
        alertController.addAction(LibAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
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

extension PlanMainVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dateCell = collectionView.dequeueReusableCellWithReuseIdentifier("DateCell", forIndexPath: indexPath)
        return dateCell
    }
}

extension PlanMainVC: UIActionSheetDelegate {
    }