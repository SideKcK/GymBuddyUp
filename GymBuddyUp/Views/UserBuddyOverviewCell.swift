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

    var user: User! {
        didSet {
            if let buddyNum = user.buddyNum {
                self.buddyNumLabel.text = String(buddyNum)
            }else {
                print("error cannot get user buddy num")
                return
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
