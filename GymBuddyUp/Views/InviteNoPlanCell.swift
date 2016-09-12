//
//  InviteNoPlanCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/24/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteNoPlanCell: UITableViewCell {
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

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
        borderView.makeBorderButton(ColorScheme.s4Bg, radius: 4.0)
        descriptionLabel.textColor = ColorScheme.g2Text
        
        titleLabel.font = FontScheme.H2
        descriptionLabel.font = FontScheme.T3
    }
}
