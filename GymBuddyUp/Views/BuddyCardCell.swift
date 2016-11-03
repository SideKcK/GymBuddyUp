//
//  BuddyCardCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/17/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

@objc protocol BuddyCardCellAddFriend {
    func buddyCardCell(buddyCardCell: BuddyCardCell, selectedUserId: String)
}

class BuddyCardCell: UITableViewCell {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var disLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var gymLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var disHeightConstraint: NSLayoutConstraint!

    var asyncIdentifer = ""
    weak var delegate: BuddyCardCellAddFriend?
    
    var buddy: User! {
        didSet {
            nameLabel.text = buddy.screenName
            if buddy.distance != nil {
            let distance = buddy.distance!/1000/1.60934
            let distanceStr = NSString(format: "%.2f", distance)
            disLabel.text = (distanceStr as String) + " miles"
            }else{
                disLabel.text = ""
            }
            var goalDes = String()
            if buddy.goals.isEmpty == false{
                print("Goal is not nil " )
                for goal in buddy.goals{
                    if goalDes != ""{
                        goalDes += ", " + goal.description
                    }else{
                        goalDes += goal.description
                    }
                }
                
            }
            
            if let googleGymObj = buddy?.googleGymObj {
                self.gymLabel.text = "Gym: " + googleGymObj.name!
            } else if let gymName = buddy?.gym {
                self.gymLabel.text = "Gym: " + gymName
            }else{
                self.gymLabel.text = "Gym: Not Specific"
            }
            
            self.goalLabel.text = "Goals: " + goalDes
            if buddy.photoURL != nil {
                self.profileView.af_setImageWithURL(buddy.photoURL!)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileView.makeThumbnail(UIColor.clearColor())
        disHeightConstraint.priority = 999
        addButton.hidden = true
        borderView.addShadow()
        setupVisual()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupVisual() {
        addButton.tintColor = ColorScheme.p1Tint
        borderView.backgroundColor = ColorScheme.s4Bg
        
        nameLabel.font = FontScheme.H2
        disLabel.font = FontScheme.T2
        goalLabel.font = FontScheme.T3
        gymLabel.font = FontScheme.T3
        
        profileView.image = UIImage(named: "dumbbell")
    }
    
    func showDistance() {
        disHeightConstraint.priority = 250
    }
    
    func addButtonOnClick() {
        delegate?.buddyCardCell(self, selectedUserId: asyncIdentifer)
    }
    
    func showAddButton() {
        addButton.hidden = false
        addButton.userInteractionEnabled = true
        addButton.addTarget(self, action: #selector(addButtonOnClick), forControlEvents: .TouchUpInside)
    }
}
