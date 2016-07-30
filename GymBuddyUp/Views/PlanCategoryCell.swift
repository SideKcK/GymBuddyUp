//
//  PlanCategoryCell.swift
//  GymBuddyUp
//
//  Created by you wu on 7/21/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanCategoryCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbnailView.makeThumbnail()

    }
}
