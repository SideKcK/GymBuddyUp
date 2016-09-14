//
//  InviteAddPlanCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/24/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteAddPlanCell: UITableViewCell {
    @IBOutlet weak var addButton: UIButton!

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
        addButton.addShadow()
    }

}
