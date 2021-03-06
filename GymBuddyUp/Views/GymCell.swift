//
//  GymCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/10/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class GymCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var thumbView: UIImageView!
   
    var gym : Gym! {
        didSet {
            nameLabel.text = gym.name
            desLabel.text = gym.address
            if let location = gym.location {
                let distance = LocationCache.sharedInstance.currentLocation.distanceFromLocation(location)
                let distanceString = String(format: "%.1f", distance / 1609.3)
                distanceLabel.text = "\(distanceString) miles"
            }
        }
    }
}
