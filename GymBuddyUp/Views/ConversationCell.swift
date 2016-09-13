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

    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        badgeLabel.layer.cornerRadius = badgeLabel.frame.size.height/2.0
        setupVisual()

    }

    func setupVisual() {
        avatarImage.makeThumbnail(UIColor.clearColor())
        borderView.backgroundColor = ColorScheme.s4Bg
        borderView.addShadow()
        screenNameLabel.font = FontScheme.H2
        lastRecordLabel.font = FontScheme.T2
        lastRecordLabel.textColor = ColorScheme.g3Text
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
