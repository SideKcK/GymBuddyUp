//
//  WorkoutCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/16/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class WorkoutCell: UITableViewCell {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var topContraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var exercisesStackView: UIStackView!
    @IBOutlet weak var locStackView: UIStackView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var timeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exercisesHeightConstraint: NSLayoutConstraint!
    
    var imageViews = [UIImageView]()
    var event: Plan! {
        didSet {
            nameLabel.text = event.name
            if let exers = event.exercises {
                if exers.count == 0 {
                    exercisesStackView.removeAllSubviews()
                    exercisesHeightConstraint.priority = 999
                }else {
                    for imageView in imageViews {
                        exercisesStackView.addArrangedSubview(imageView)
                    }
                    exercisesHeightConstraint.priority = 250
                }
                for (index, exer) in exers.enumerate() {
                    if index > 5 {
                        print("reassign image view")
                        imageViews[5].image = UIImage(named: "dumbbell")
                        //change last imageView
                        break
                    }else {
                        let downloadURL = exer.thumbnailURL
                        let imageView = imageViews[index]
                        imageView.af_setImageWithURL(downloadURL)
                        imageView.makeThumbnail()
                    }
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        borderView.addShadow()
        clearAllViews()
        for _ in 0...5 {
            let width = exercisesStackView.frame.height - 4.0
            let imageView = UIImageView(frame: CGRectMake(0, 0, width, width))
            //imageView.heightAnchor.constraintEqualToConstant(width).active = true
            imageView.widthAnchor.constraintEqualToConstant(width).active = true
            imageView.heightAnchor.constraintEqualToAnchor(imageView.widthAnchor).active = true
            imageView.contentMode = .ScaleAspectFill
            exercisesStackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func clearAllViews() {
        profileView.hidden = true
        profileLabel.hidden = true
        topContraint.constant = 8
        moreButton.hidden = true
        timeHeightConstraint.priority = 999
        statusHeightConstraint.priority = 999
        locHeightConstraint.priority = 999
    }
    
    func showMoreButton() {
        moreButton.hidden = false
    }
    
    func showProfileView() {
        profileView.hidden = false
        profileLabel.hidden = false
        topContraint.constant = 40
        profileView.makeThumbnail()
    }
    
    func showTimeView() {
        timeHeightConstraint.priority = 250
    }
    
    func showLocView() {
        exercisesStackView.alignment = .Center
        locHeightConstraint.priority = 250
    }
    
    func showStatusView() {
        exercisesStackView.alignment = .Center
        statusHeightConstraint.priority = 250
    }
    
    
}
