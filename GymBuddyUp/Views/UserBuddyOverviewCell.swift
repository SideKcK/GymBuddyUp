//
//  UserBuddyOverviewCell.swift
//  GymBuddyUp
//
//  Created by you wu on 7/10/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class UserBuddyOverviewCell: UITableViewCell {
    @IBOutlet weak var buddyNumLabel: UILabel!
    @IBOutlet weak var buddyLabel: UILabel!
    @IBOutlet weak var buddyView: UIImageView!

    var user: User! {
        didSet {
            if let buddyNum = user.buddyNum {
                //self.buddyNumLabel.text = String(buddyNum)
            }else {
                print("error cannot get user buddy num")
                return
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupVisual()
    }
    
    func setupVisual() {
        self.backgroundColor = ColorScheme.p1Tint
        buddyNumLabel.textColor = ColorScheme.g4Text
        buddyLabel.textColor = ColorScheme.g4Text
        buddyView.tintColor = ColorScheme.s4Bg
        let text = FontScheme.T3
        buddyNumLabel.font = text
        buddyLabel.font = text
    }

}
