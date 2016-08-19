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
    @IBOutlet weak var profileTapView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var exercisesStackView: UIStackView!
    @IBOutlet weak var locStackView: UIStackView!
    
    @IBOutlet weak var gymButton: UIButton!
    @IBOutlet weak var gymDisLabel: UILabel!
    @IBOutlet weak var buddyButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
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
                        imageView.image = UIImage()
                        imageView.layer.borderWidth = 0.0
                        exercisesStackView.addArrangedSubview(imageView)
                    }
                    exercisesHeightConstraint.priority = 250
                
                    for index in 0...(exers.count - 1) {
                    imageViews[index].makeThumbnail()
                    if exers.count > 6 && index == 5 {
                        imageViews[index].image = UIImage(named: "dumbbell")
                        //change last imageView
                        break
                    }else {
                        let downloadURL = exers[index].thumbnailURL
                        imageViews[index].af_setImageWithURL(downloadURL)
                    }

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
        profileTapView.userInteractionEnabled = true
        selectionStyle = .None
        for _ in 0...5 {
            let width = exercisesStackView.frame.height - 4.0
            let imageView = UIImageView(frame: CGRectMake(0, 0, width, width))

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
        buddyButton.hidden = true
        gymButton.hidden = true
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
        gymButton.hidden = false
    }
    
    func showStatusView() {
        exercisesStackView.alignment = .Center
        statusHeightConstraint.priority = 250
        buddyButton.hidden = false
    }
    
    
}
