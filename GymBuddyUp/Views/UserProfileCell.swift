//
//  UserProfileCell.swift
//  GymBuddyUp
//
//  Created by you wu on 7/10/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class UserProfileCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workoutNumLabel: UILabel!
    @IBOutlet weak var likeNumLabel: UILabel!
    @IBOutlet weak var starNumLabel: UILabel!
    @IBOutlet weak var workoutNameLabel: UILabel!
    
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var gymNameLabel: UILabel!
    @IBOutlet weak var goalLeading: NSLayoutConstraint!
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var gymLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var requestStack: UIStackView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!

    
    // FIXME: should not put model info in views
    var user: User! {
        didSet {
            if let screenName = user.screenName,
                let workoutNum = user.workoutNum,
                let goal = user.goal,
                let gym = user.gym,
                let description = user.description
            {
                self.nameLabel.text = screenName
                self.workoutNumLabel.text = String(workoutNum)
                self.goalLabel.text = goal.description
                self.gymLabel.text = gym
                self.descriptionLabel.text = description
                
            } else {
                    print("error cannot get user profile") //TBD error class
                    return
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupVisual()
        
        //if user = currentuser
        requestStack.hidden = true
    }
    
    func setupVisual() {
        goalLeading.constant = self.frame.width / 4.0
        let grey = ColorScheme.g2Text
        actionButton.makeBorderButton(grey, radius: 8.0)
        actionButton.setTitleColor(grey, forState: .Normal)
        acceptButton.makeBorderButton(ColorScheme.p1Tint, radius: 8.0)
        rejectButton.makeBorderButton(ColorScheme.e1Tint, radius: 8.0)
        
        goalNameLabel.textColor = grey
        gymNameLabel.textColor = grey
        
        let text = FontScheme.T1
        let smallText = FontScheme.T3
        nameLabel.font = FontScheme.H1
        actionButton.titleLabel?.font = text
        goalLabel.font = text
        goalNameLabel.font = text
        gymLabel.font = text
        gymNameLabel.font = text
        descriptionLabel.font = smallText
        workoutNumLabel.font = smallText
        workoutNameLabel.font = smallText
        
    }
}
