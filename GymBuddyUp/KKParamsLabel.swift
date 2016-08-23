//
//  KKParamsLabel.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/18/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class KKParamsLabel: UILabel {
    var bottomBorderCA: CALayer?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // because storyboard has intrinsic width (4s for inferred size), when this view shows on bigger screen, we need to update bounds as well (Maybe it's a bug??)

        self.bottomBorderCA?.frame = CGRectMake(0.0, self.frame.size.height - 1, self.frame.size.width, 1.0)
    }
    
    override func awakeFromNib() {
        self.bottomBorderCA = self.setBottomBorderCA(color: ColorScheme.trackingNavigationParamsLabel)
    }

}
