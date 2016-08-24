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
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteLeading: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    
    var originalLeading: CGFloat!
    var deleteOnDragRelease = false
    var cancelOnDragRelease = false
    
    var message : String! {
        didSet {
            nameLabel.text = "test message name"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //TEST
        timeLabel.text = "at "+timeString(NSDate())+" on "+weekMonthDateString(NSDate())
        
        borderView.addShadow()
        profileView.makeThumbnail(ColorScheme.s4Bg)
        deleteButton.layer.cornerRadius = 5
        reset()
        setupVisual()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupVisual() {
        acceptButton.tintColor = ColorScheme.p1Tint
        cancelButton.tintColor = ColorScheme.e1Tint
        borderView.backgroundColor = ColorScheme.s4Bg
        
        nameLabel.font = FontScheme.H2
        timeLabel.font = FontScheme.T2
        statusLabel.font = FontScheme.T3
        
    }
    
    func reset() {
        timeHeight.priority = 999
        buttonHeight.priority = 999
        indicatorView.hidden = true
        acceptButton.hidden = true
        cancelButton.hidden = true
    }
    
    func showIndicator(positive: Bool) {
        indicatorView.hidden = false
        indicatorView.backgroundColor = positive ? ColorScheme.p1Tint : ColorScheme.e1Tint
    }
    
    func showButtons() {
        buttonHeight.priority = 250
        acceptButton.hidden = false
        cancelButton.hidden = false
    }
    
    func showTime() {
        timeHeight.priority = 250

    }
    
}
