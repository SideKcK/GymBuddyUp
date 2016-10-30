//
//  MessageCell.swift
//  GymBuddyUp
//
//  Created by you wu on 8/19/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

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
    
    var asyncId = ""
    var bindedUserId: String? {
        didSet {
            let currentAsyncId = asyncId
            if let userId = bindedUserId {
                if let user = UserCache.sharedInstance.cache[userId] {
                    self.nameLabel.text = user.screenName
                    if let photoURL = user.photoURL where user.cachedPhoto == nil {
                        let request = NSMutableURLRequest(URL: photoURL)
                        self.profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                            if currentAsyncId == self.asyncId {
                                self.profileView.image = response.result.value
                                user.cachedPhoto = response.result.value
                            }
                        }
                    } else {
                        self.profileView.image = user.cachedPhoto
                    }
                } else {
                    User.getUserArrayFromIdList([userId]) { (users: [User]) in
                        if currentAsyncId == self.asyncId {
                            let user = users[0]
                            self.nameLabel.text = user.screenName
                            UserCache.sharedInstance.cache[userId] = user
                            if let photoURL = user.photoURL {
                                let request = NSMutableURLRequest(URL: photoURL)
                                self.profileView.af_setImageWithURLRequest(request, placeholderImage: UIImage(named: "selfie"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.None, runImageTransitionIfCached: false) { (response: Response<UIImage, NSError>) in
                                    if currentAsyncId == self.asyncId {
                                        self.profileView.image = response.result.value
                                        user.cachedPhoto = response.result.value
                                    }
                                }
                                
                            }
                        }
                    }
                }
            
            
            }
        }
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //TEST
        timeLabel.text = "at " + timeString(NSDate()) + " on " + weekMonthDateString(NSDate())
        
        borderView.addShadow()
        profileView.makeThumbnail(ColorScheme.s4Bg)
        deleteButton.layer.cornerRadius = 5
        reset()
        setupVisual()
        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupVisual() {
        acceptButton.tintColor = ColorScheme.p1Tint
        cancelButton.tintColor = ColorScheme.e1Tint
        borderView.backgroundColor = ColorScheme.s4Bg
        
        nameLabel.font = FontScheme.H2
        timeLabel.font = FontScheme.T2
        statusLabel.font = FontScheme.T3
        timeLabel.textColor = ColorScheme.g2Text
    }
    
    func reset() {
        timeHeight.priority = 999
        buttonHeight.priority = 999
        indicatorView.hidden = true
        acceptButton.hidden = true
        cancelButton.hidden = true
    }
    
    func showIndicator(positive: Bool) {
        indicatorView.hidden = false
        indicatorView.backgroundColor = positive ? ColorScheme.p1Tint : ColorScheme.e1Tint
    }
    
    func showButtons() {
        buttonHeight.priority = 250
        acceptButton.hidden = false
        cancelButton.hidden = false
    }
    
    func showTime() {
        timeHeight.priority = 250

    }
    
}
