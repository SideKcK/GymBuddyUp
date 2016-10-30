//
//  MeUpdateVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

@objc protocol updateMeDelegate {
    optional func syncAfterUpdateMe(updatedGymPlaceId: String?, updatedGymObj: Gym?,updatedGoals: Set<Int>, updatedProfile: UIImage?)
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

    private func fetchAvatar(url: NSURL) {
        let request = NSMutableURLRequest(URL: url)
        thumbView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
            self.thumbView.image = response.result.value
        }
        
        thumbView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
            self.thumbView.image = response.result.value
        }
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
        if let photoURL = user.photoURL {
            fetchAvatar(photoURL)
        } else {
            User.currentUser?.syncWithLastestUserInfo({
                if let photoURL = self.user.photoURL {
                    self.fetchAvatar(photoURL)
                }
            })
        }
        
        for goal in user.goals {
            
            if(goal.rawValue == 0){
                //weightButton.selected = true
                buttonClicked(weightButton)
            }else if(goal.rawValue == 1){
               // fitButton.selected = true
                buttonClicked(fitButton)
            }else if(goal.rawValue == 2){
                //funButton.selected = true
                buttonClicked(funButton)
            }else if(goal.rawValue == 3){
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
        thumbView.userInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileTap))
        thumbView.addGestureRecognizer(tapRecognizer)
        gym1Button.addTarget(self, action: #selector(MeUpdateVC.onGymButton(_:)), forControlEvents: .TouchUpInside)
    }
    
    func profileTap() {
        Log.info("taped on thumbView")
        let vc = UIImagePickerController()
        vc.delegate = self
        
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
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
        User.currentUser?.updateScreenNameInAuth(screenNameField.text, errorHandler: { (error: NSError?) in
            Log.error("update screenName error = \(error?.localizedDescription)")
        })
        User.currentUser?.updateProfile("goal", value: self.selected)
        User.currentUser?.updateProfile("description", value: textView.text)
        if gym != nil{
            User.currentUser!.updateProfile("gym", value: gym!.placeid)
        }
        delegate?.syncAfterUpdateMe?(gym?.placeid, updatedGymObj: gym, updatedGoals: self.selected, updatedProfile: thumbView.image)
        self.performSegueWithIdentifier("unwindToMeMainVC", sender: self)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Change the color of all cells
        cell.backgroundColor = UIColor.clearColor()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let desVC = segue.destinationViewController as? InviteGymVC {
            desVC.from = self
        }
    }
}


extension MeUpdateVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        let image = editedImage.imageScaledToSize(CGSizeMake(500, 500))
        thumbView.image = image
        thumbView.image = image
        
        //TODO: dont know why it's failing
        //KRProgressHUD.show()
        user.updateProfilePicture(image){ error in
            if error != nil {
                print("Error setting profile picture \(error?.localizedFailureReason)")
                //KRProgressHUD.showError()
            } else {
                //KRProgressHUD.dismiss()
                Log.info("Setting successfully!")
                self.tableView.reloadData()
            }
        }
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
}
