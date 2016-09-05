//
//  ConversationCell.swift
//  GymBuddyUp
//
//  Created by YiHuang on 9/4/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!

    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var lastRecordLabel: UILabel!
    
    @IBOutlet weak var badgeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height/2.0;

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
