//
//  ExerciseNumberedCell.swift
//  GymBuddyUp
//
//  Created by you wu on 7/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ExerciseNumberedCell: UITableViewCell {
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    var exercise: Exercise! {
        
        didSet {
            let downloadURL = exercise.thumbnailURL
            self.thumbnailView.af_setImageWithURL(downloadURL)
            self.thumbnailView.makeThumbnail(ColorScheme.g2Text)
            self.nameLabel.text = exercise.name
            guard let amount = exercise.set[0]?.amount else{
                return
            }
            switch exercise.unitType! {
            case Exercise.UnitType.Repetition, Exercise.UnitType.RepByWeight:
                self.amountLabel.text = String(exercise.set.count) + " sets"
            case Exercise.UnitType.DurationInSeconds:
                self.amountLabel.text = String(amount) + " seconds"
            case Exercise.UnitType.DistanceInMiles:
                self.amountLabel.text = String(amount) + " miles"
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func setupVisual() {
        numLabel.font = FontScheme.N3
        nameLabel.font = FontScheme.T1
        amountLabel.font = FontScheme.T3
    }
}
