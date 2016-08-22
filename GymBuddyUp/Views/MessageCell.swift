//
//  MessageCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteLeading: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    
    var originalLeading: CGFloat!
    var deleteOnDragRelease = false
    var cancelOnDragRelease = false
    
    var message : String! {
        didSet {
            nameLabel.text = "test message name"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        borderView.addShadow()
        profileView.makeThumbnail()
        deleteButton.layer.cornerRadius = 5
        reset()
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(MessageCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
        deleteLeading.constant = -deleteButton.bounds.width - 20
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func reset() {
        timeHeight.priority = 999
        buttonHeight.priority = 999
        indicatorView.hidden = true
    }
    
    func showIndicator(positive: Bool) {
        indicatorView.hidden = false
        indicatorView.backgroundColor = positive ? ColorScheme.sharedInstance.buttonTint : UIColor.flatRedColor()
    }
    
    func showButtons() {
        buttonHeight.priority = 250
    }
    
    func showTime() {
        timeHeight.priority = 250

    }
    
}

extension MessageCell {
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .Began {
            // when the gesture begins, record the current center location
            originalLeading = deleteLeading.constant
            
        }
        // 2
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            deleteLeading.constant = originalLeading - translation.x
            //center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = translation.x < -frame.size.width / 4.0
            cancelOnDragRelease = translation.x > frame.size.width / 8.0
            
        }
        // 3
        if recognizer.state == .Ended {
            // the frame this cell had before user dragged it
            
            // if the item is not being deleted, snap back to the original location
            UIView.animateWithDuration(0.3, animations: {
                self.deleteLeading.constant = self.deleteOnDragRelease && !self.cancelOnDragRelease ? 20.0 : -self.deleteButton.bounds.width - 20
            })
            
        }
    }

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}
