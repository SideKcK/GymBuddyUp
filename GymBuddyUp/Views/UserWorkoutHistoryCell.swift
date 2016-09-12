//
//  UserWorkoutHistoryCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class UserWorkoutHistoryCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var buddyButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupVisual()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupVisual() {
        self.backgroundColor = ColorScheme.s3Bg
        let text = FontScheme.T3
        let mtext = FontScheme.T2
        timeLabel.font = mtext
        workoutLabel.font = text
        buddyButton.setTitleColor(ColorScheme.p1Tint, forState: .Normal)
        buddyButton.titleLabel?.font = mtext
    }
}
