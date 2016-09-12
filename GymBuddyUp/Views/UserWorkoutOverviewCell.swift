//
//  UserWorkoutOverviewCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/23/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class UserWorkoutOverviewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!

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
        nameLabel.font = FontScheme.T3
    }
}
