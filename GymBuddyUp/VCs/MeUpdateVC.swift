//
//  MeUpdateVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

@objc protocol updateMeDelegate {
    optional func syncAfterUpdateMe(updatedGymPlaceId: String, updatedGymObj: Gym?,updatedGoals: Set<Int>)
}

class MeUpdateVC: UITableViewController {
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var muscleButton: UIButton!
    @IBOutlet weak var fitButton: UIButton!
    @IBOutlet weak var funButton: UIButton!
    @IBOutlet weak var gym1Button: UIButton!

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var thumbView: UIImageView!

    @IBOutlet weak var screenNameField: UITextField!
    
    var user: User!
    var gym: Gym!
    var selected = Set<Int>()
    var tintColor = ColorScheme.p1Tint
    var delegate: updateMeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //for testing
        
        setupVisual()
        setupButtons()
        setupInfo()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func unwindToMeUpdateVC(segue: UIStoryboardSegue) {
        print(gym.name)
    }
    
    func setupInfo(){
        screenNameField.text = user.screenName
        
            for goal in user.goals {
                
                if(goal.rawValue == 0){
                    //weightButton.selected = true
                    print("0")
                    buttonClicked(weightButton)
                }else if(goal.rawValue == 1){
                   // fitButton.selected = true
                    print("1")
                    buttonClicked(fitButton)
                }else if(goal.rawValue == 2){
                    print("2")
                    //funButton.selected = true
                    buttonClicked(funButton)
                }else if(goal.rawValue == 3){
                    print("3")
                    //muscleButton.selected = true
                    buttonClicked(muscleButton)
                }
            }
        
        gym1Button.setTitle(user.gym, forState: UIControlState.Normal)
        if let _description = user.description {
            textView.text = _description
        }else{
            textView.text = ""
        }
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
        
        textView.makeBorderButton(grey, radius: radius)
    }
    
    func setupButtons() {
        weightButton.tag = 0
        fitButton.tag = 1
        funButton.tag = 2
        muscleButton.tag = 3
        setButton(weightButton)
        setButton(fitButton)
        setButton(funButton)
        setButton(muscleButton)
        
        gym1Button.addTarget(self, action: #selector(MeUpdateVC.onGymButton(_:)), forControlEvents: .TouchUpInside)
    }
    
    func setButton (button: UIButton) {
        button.makeBorderButton(tintColor, radius: 2.0)
        if selected.contains(button.tag) {
            button.backgroundColor = tintColor
            button.setTitleColor(ColorScheme.s4Bg, forState: .Normal)
        }
        button.addTarget(self, action: #selector(SetGoalVC.buttonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }

    func buttonClicked(sender:UIButton) {
        sender.selected = !sender.selected
        if (sender.selected) {
            selected.insert(sender.tag)
            sender.backgroundColor = tintColor
            sender.setTitleColor(ColorScheme.s4Bg, forState: .Normal)
        }else {
            selected.remove(sender.tag)
            sender.setTitleColor(tintColor, forState: .Normal)
            sender.backgroundColor = ColorScheme.s4Bg
        }
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
        User.currentUser!.updateProfile("screen_name", value: screenNameField.text)
        User.currentUser!.updateProfile("goal", value: self.selected)
        User.currentUser!.updateProfile("description", value: textView.text)
        if gym != nil{
            User.currentUser!.updateProfile("gym", value: gym!.placeid)
        }
        delegate?.syncAfterUpdateMe?(gym.placeid!, updatedGymObj: gym, updatedGoals: self.selected)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteGymVC {
            desVC.from = self
        }
    }
    

}
