//
//  InviteDateCell.swift
//  GymBuddyUp
//
//  Created by you wu on 9/13/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

@objc protocol InviteDatePickerOnPicked {
    optional func datePicker(datePicker: UIDatePicker)
}

class InviteDateCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    weak var delegate: InviteDatePickerOnPicked?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDate()
        setupVisual()
        
    }
    
    @IBAction func onDatePicked(sender: AnyObject) {
        delegate?.datePicker?(datePicker)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupVisual() {
        dateButton.addShadow()
        dateButton.tintColor = ColorScheme.p1Tint
        dateLabel.font = FontScheme.T1
        datePicker.backgroundColor = ColorScheme.s4Bg
    }
    
    func setDate(date: NSDate) {
        datePicker.datePickerMode = UIDatePickerMode.Time
        datePicker.addTarget(self, action: #selector(InviteDateCell.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        datePicker.minimumDate = date
        
        //change the date to actual date selected
        dateButton.setTitle(dateTimeFormatter().stringFromDate(date), forState: UIControlState.Normal)
        
    }
    
    func setDate() {
        datePicker.datePickerMode = UIDatePickerMode.Time
        datePicker.addTarget(self, action: #selector(InviteDateCell.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        datePicker.minimumDate = NSDate()
        //change the date to actual date selected
        dateButton.setTitle(dateTimeFormatter().stringFromDate(NSDate()), forState: UIControlState.Normal)
        
    }

    func datePickerValueChanged(sender: UIDatePicker) {
        dateButton.setTitle(dateTimeFormatter().stringFromDate(sender.date), forState: UIControlState.Normal)
    }
}
