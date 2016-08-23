//
//  TrackedItemPopoverCell.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class TrackedItemPopoverCell: UITableViewCell {
    
    @IBOutlet weak var exerciseIconImageView: UIImageView!
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var progressDescriptionLabel: UILabel!
    @IBOutlet weak var statusIndicatorImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
