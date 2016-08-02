//
//  MultilineSegControl.swift
//  GymBuddyUp
//
//  Created by you wu on 8/1/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MultilineSegControl: UISegmentedControl {

    override func didMoveToSuperview()
    {
        for segment in subviews
        {
            for subview in segment.subviews
            {
                if let segmentLabel = subview as? UILabel
                {
                    segmentLabel.numberOfLines = 2
                }
            }
        }
    }

}
