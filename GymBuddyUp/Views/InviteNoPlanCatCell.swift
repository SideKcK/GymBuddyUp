//
//  InviteNoPlanCatCell.swift
//  GymBuddyUp
//
//  Created by you wu on 9/12/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteNoPlanCatCell: UITableViewCell {
    @IBOutlet weak var catLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupVisual()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupVisual () {
        catLabel.font = FontScheme.H2
    }
}
