//
//  BuddyCardCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/17/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class BuddyCardCell: UITableViewCell {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var disLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var gymLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var disHeightConstraint: NSLayoutConstraint!

    var buddy: String! {
        didSet {
            nameLabel.text = buddy
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        disHeightConstraint.priority = 999
        addButton.hidden = true
        borderView.addShadow()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func showDistance() {
        disHeightConstraint.priority = 250
    }
    
    func showAddButton() {
        addButton.hidden = false
    }
}