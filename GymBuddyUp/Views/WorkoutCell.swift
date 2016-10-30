//
//  WorkoutCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/16/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class WorkoutCell: UITableViewCell {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var topContraint: NSLayoutConstraint!
    @IBOutlet weak var profileTapView: UIView!
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var exercisesStackView: UIStackView!
    @IBOutlet weak var locStackView: UIStackView!
    
    @IBOutlet weak var gymButton: UIButton!
    @IBOutlet weak var gymDisLabel: UILabel!
    @IBOutlet weak var buddyButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var nameDateConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exercisesHeightConstraint: NSLayoutConstraint!
    
    var asyncIdentifer = ""
    var workouttime : NSDate?
    var imageViews = [UIImageView]()
    var event: Invite! {
        didSet {
            print("event: Invite")
            timeLabel.text = weekMonthDateString(event.workoutTime) + ", " + timeString(event.workoutTime)
            gymButton.setTitle(event.gym?.name, forState: .Normal)
            
        }
    }
    
    var invite: Invite? {
        didSet {
            print("invite: Invite")
            if let _invite = invite {
                if let workoutTime = _invite.workoutTime {
                    timeLabel.text = weekMonthDateString(workoutTime) + ", " + timeString(workoutTime)
                    
                }
                
                if let gymName = _invite.gym?.name {
                    gymButton.setTitle(gymName, forState: .Normal)
                }
                
                if let location = invite?.gym?.location {
                    let distance = LocationCache.sharedInstance.currentLocation.distanceFromLocation(location)
                    let distanceString = String(format: "%.1f", distance / 1609.3)
                    gymDisLabel.text = "\(distanceString) miles"
                }
                
            }
        
        }
    }
    
    var plan: Plan! {
        didSet {
            let currentDate = NSDate()
            let interval = NSTimeInterval(60 * 60 * 24 * 1)
            if let workoutTime = self.workouttime {
                if weekMonthDateString(workoutTime) == weekMonthDateString(currentDate){
                    dateLabel.text = "Today"
                }else if weekMonthDateString(workoutTime) == weekMonthDateString(currentDate.dateByAddingTimeInterval(interval)) {
                    dateLabel.text = "Tomorrow"
                }else{
                    dateLabel.text =  weekMonthDateString(workoutTime) + ", " + timeString(workoutTime)
                }
            }
            //dateLabel.text = "Today"
            nameLabel.text = plan.name
            if let exers = plan.exercises {
                if exers.count == 0 {
                    exercisesStackView.removeAllSubviews()
                    exercisesHeightConstraint.priority = 999
                }else {
                    for imageView in imageViews {
                        imageView.image = UIImage()
                        imageView.layer.borderWidth = 0.0
                        exercisesStackView.addArrangedSubview(imageView)
                    }
                    exercisesHeightConstraint.priority = 250
                
                    for index in 0...(exers.count - 1) {
                    imageViews[index].makeThumbnail(ColorScheme.g3Text)
                    if exers.count > 6 && index == 5 {
                        imageViews[index].image = UIImage(named: "more_exercise")
                        //change last imageView
                        break
                    }else {
                        if let downloadURL = exers[index].thumbnailURL{
                            imageViews[index].af_setImageWithURL(downloadURL)
                        }else{
                            imageViews[index].hidden = true
                        }
                    }

                }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        for _ in 0...5 {
            let width = CGFloat(35.0)
            let imageView = UIImageView(frame: CGRectMake(0, 0, width, width))

            imageView.widthAnchor.constraintEqualToConstant(width).active = true
            imageView.heightAnchor.constraintEqualToAnchor(imageView.widthAnchor).active = true
            imageView.contentMode = .ScaleAspectFill
            exercisesStackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
        }
        
        borderView.addShadow()
        clearAllViews()
        setupVisual()
        profileTapView.userInteractionEnabled = true
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setupVisual() {
        dateView.layer.addBorder(.Bottom, color: ColorScheme.g2Text, thickness: 1.0)
        dateLabel.textColor = ColorScheme.g2Text
        moreButton.tintColor = ColorScheme.g2Text
        gymButton.tintColor = ColorScheme.p1Tint
        buddyButton.tintColor = ColorScheme.p1Tint
        borderView.backgroundColor = ColorScheme.s4Bg
        borderView.layer.borderColor = ColorScheme.p1Tint.CGColor

        dateLabel.font = FontScheme.T3
        profileView.layer.borderWidth = 0.5
        profileLabel.font = FontScheme.T3
        nameLabel.font = FontScheme.H2
        timeLabel.font = FontScheme.H2
        gymButton.titleLabel?.font = FontScheme.T2
        gymDisLabel.font = FontScheme.T3
        statusLabel.font = FontScheme.T3
        buddyButton.titleLabel?.font = FontScheme.T2
        profileView.image = UIImage(named: "dumbbell")
        
    }

    func clearAllViews() {
        borderView.alpha = 1
        Log.info("clearAllViews")
        userInteractionEnabled = true
        profileView.hidden = true
        profileLabel.hidden = true
        topContraint.constant = 8
        moreButton.hidden = true
        buddyButton.hidden = true
        gymButton.hidden = true
        dateView.hidden = true
        dateLabel.hidden = true
        
        dateHeightConstraint.priority = 999
        timeHeightConstraint.priority = 999
        statusHeightConstraint.priority = 999
        locHeightConstraint.priority = 999
        
        nameDateConstraint.constant = 0
    }
    
    func showMoreButton() {
        moreButton.hidden = false
    }
    
    func hideMoreButton() {
        moreButton.hidden = true
    }
    
    func showProfileView() {
        profileView.hidden = false
        profileLabel.hidden = false
        topContraint.constant = 40
        profileView.makeThumbnail(ColorScheme.p1Tint)
    }
    
    func showDateView() {
        nameDateConstraint.constant = 8
        dateHeightConstraint.priority = 250
        dateLabel.hidden = false
        dateView.hidden = false
    }
    func showTimeView() {
        timeHeightConstraint.priority = 250
    }
    
    func showLocView() {
        exercisesStackView.alignment = .Center
        locHeightConstraint.priority = 250
        gymButton.hidden = false
    }
    
    func showStatusView() {
        exercisesStackView.alignment = .Center
        statusHeightConstraint.priority = 250
        buddyButton.hidden = false
    }
    
    
}
