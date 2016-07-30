//
//  ExerciseNumberedCell.swift
//  GymBuddyUp
//
//  Created by you wu on 7/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class ExerciseNumberedCell: UITableViewCell {
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
