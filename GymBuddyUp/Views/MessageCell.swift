//
//  MessageCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var indicatorView: UIView!

    var message : String! {
        didSet {
            nameLabel.text = "test message name"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        borderView.addShadow()
        profileView.makeThumbnail()
        reset()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reset() {
        timeHeight.priority = 999
        buttonHeight.priority = 999
        indicatorView.hidden = true
    }
    
    func showIndicator(positive: Bool) {
        indicatorView.hidden = false
        indicatorView.backgroundColor = positive ? ColorScheme.sharedInstance.buttonTint : UIColor.flatRedColor()
    }
    
    func showButtons() {
        buttonHeight.priority = 250
    }
    
    func showTime() {
        timeHeight.priority = 250

    }
    
}
