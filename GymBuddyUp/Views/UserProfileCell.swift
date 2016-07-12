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
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var gymLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var user: User! {
        didSet {
            if let screenName = user.screenName,
                let workoutNum = user.workoutNum,
                let likeNum = user.likeNum,
                let starNum = user.starNum,
                let goal = user.goal,
                let gym = user.gym,
                let description = user.description
            {
                self.nameLabel.text = screenName
                self.workoutNumLabel.text = String(workoutNum)
                self.likeNumLabel.text = String(likeNum)
                self.starNumLabel.text = String(starNum)
                self.goalLabel.text = User.toString(goal)
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
    }



}
