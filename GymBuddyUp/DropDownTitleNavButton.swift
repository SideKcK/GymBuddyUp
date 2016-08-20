//
//  DropDownTitleNavButton.swift
//  GymBuddyUp
//
//  Created by YiHuang on 8/19/16.
//

import UIKit

@objc protocol DropDownTitleNavButtonDelegate {
    optional func dropDownTitleNavButton(button: DropDownTitleNavButton)
}


class DropDownTitleNavButton: UIView {
    var title: String = "/" {
        didSet {
            label.text = title
        }
    }
    lazy var label = UILabel()
    lazy var dropDownButton = UIImageView()
    var delegate: DropDownTitleNavButtonDelegate?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupButton()
    }

    func dropDownAction(sender: UITapGestureRecognizer) {
        self.delegate?.dropDownTitleNavButton?(self)
    }
    
    
    func setupButton() {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - 20, height: frame.height))
        label.text = title
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.addSubview(label)

        dropDownButton = UIImageView(frame: CGRect(x: frame.width - 20, y: frame.height/3, width: 12, height: 12))
        dropDownButton.image = UIImage(named: "expand-arrow")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dropDownAction(_:)))
        self.addGestureRecognizer(tapGesture)
        self.addSubview(dropDownButton)
    }
}
