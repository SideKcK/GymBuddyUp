//
//  InviteGymCell.swift
//  GymBuddyUp
//
//  Created by you wu on 9/13/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteGymCell: UITableViewCell {

    @IBOutlet weak var gymLabel: UILabel!
    @IBOutlet weak var gymButton: UIButton!
    
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
        gymButton.addShadow()
        gymButton.tintColor = ColorScheme.p1Tint
        gymLabel.font = FontScheme.T1

    }
}
