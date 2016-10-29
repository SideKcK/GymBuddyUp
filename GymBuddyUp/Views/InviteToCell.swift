//
//  InviteToCell.swift
//  GymBuddyUp
//
//  Created by you wu on 9/13/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteToCell: UITableViewCell {
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toView: UIView!
    
    var seg: UISegmentedControl!
    var segViews: [UIView]!
    var sendTo = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupVisual()
        setSegControl()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // because storyboard has intrinsic width (4s for inferred size), when this view shows on bigger screen, we need to update bounds as well (Maybe it's a bug??)
        seg.frame = toView.bounds
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupVisual() {
        toLabel.font = FontScheme.T1
    }

    func setSegControl() {
        
        UILabel.appearanceWhenContainedInInstancesOfClasses([UISegmentedControl.self]).numberOfLines = 0
        seg = UISegmentedControl(items: ["Direct Invite", "Broadcast\nBuddies", "Broadcast\nPublic"])
        
        
        seg.addShadow()
        seg.tintColor = ColorScheme.g3Text
        seg.removeBorders()
        segViews = seg.subviews
        seg.selectedSegmentIndex = sendTo
        seg.momentary = true
        segViews[sendTo].tintColor = ColorScheme.p1Tint
        seg.selectedSegmentIndex = UISegmentedControlNoSegment
        seg.frame = toView.bounds
        toView.addSubview(seg)
        
    }
    
}
