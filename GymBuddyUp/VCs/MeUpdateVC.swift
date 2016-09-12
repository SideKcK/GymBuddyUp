//
//  MeUpdateVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MeUpdateVC: UITableViewController {
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var muscleButton: UIButton!
    @IBOutlet weak var fitButton: UIButton!
    @IBOutlet weak var funButton: UIButton!
    @IBOutlet weak var gym1Button: UIButton!
    @IBOutlet weak var gym2Button: UIButton!
    @IBOutlet weak var gym3Button: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var thumbView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisual()
        setupButtons()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupVisual() {
        
        self.tableView.backgroundColor = ColorScheme.s3Bg
        thumbView.makeThumbnail(ColorScheme.p1Tint)
        profileView.layer.addBorder(.Bottom, color: ColorScheme.g2Text, thickness: 0.5)
        let radius = CGFloat(4.0)
        let tint = ColorScheme.p1Tint
        weightButton.makeBorderButton(tint, radius: radius)
        muscleButton.makeBorderButton(tint, radius: radius)
        fitButton.makeBorderButton(tint, radius: radius)
        funButton.makeBorderButton(tint, radius: radius)
        let grey = ColorScheme.g2Text
        gym1Button.makeBorderButton(grey, radius: radius)
        gym2Button.makeBorderButton(grey, radius: radius)
        gym3Button.makeBorderButton(grey, radius: radius)
        textView.makeBorderButton(grey, radius: radius)
    }
    
    func setupButtons() {
        gym1Button.addTarget(self, action: #selector(MeUpdateVC.onGymButton(_:)), forControlEvents: .TouchUpInside)
        gym2Button.addTarget(self, action: #selector(MeUpdateVC.onGymButton(_:)), forControlEvents: .TouchUpInside)
        gym3Button.addTarget(self, action: #selector(MeUpdateVC.onGymButton(_:)), forControlEvents: .TouchUpInside)
    }
    
    func onGymButton (sender: UIButton) {
        self.performSegueWithIdentifier("toGymSegue", sender: sender)
    }
    @IBAction func onCancelButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: "Leave Without Saving?", preferredStyle: .ActionSheet)
        alertController.customize()
        let leaveAction = UIAlertAction(title: "Leave", style: .Destructive) { (action) in
            self.performSegueWithIdentifier("unwindToMeMainVC", sender: self)
        }
        alertController.addAction(leaveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onSaveButton(sender: AnyObject) {
        //save changes
        self.performSegueWithIdentifier("unwindToMeMainVC", sender: self)
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Change the color of all cells
        cell.backgroundColor = UIColor.clearColor()
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
