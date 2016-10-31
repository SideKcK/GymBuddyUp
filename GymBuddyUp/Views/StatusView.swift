//
//  StatusView.swift
//  GymBuddyUp
//
//  Created by you wu on 9/11/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class StatusView: UIView {
    var view: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    /**
     Initialiser method
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /**
     Initialiser method
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        view = loadViewFromXibFile()
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        borderView.makeBorderButton(ColorScheme.p1Tint, radius: 3.0)
        
        view.userInteractionEnabled = true
        closeButton.addTarget(self, action: #selector(StatusView.closeButtonTapped(_:)), forControlEvents: .TouchDown)
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        let margins = self.layoutMarginsGuide
        view.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: 0).active = true
        
        view.centerXAnchor.constraintEqualToAnchor(margins.centerXAnchor).active = true
        view.needsUpdateConstraints()
        
    }
    
    func loadViewFromXibFile() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "StatusView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func setMessage(mes: String) {
        messageLabel.text = mes
    }
    
    private func hideView() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 0.0
        }) { (finished) -> Void in
            self.removeFromSuperview()
        }
    }
    
    func displayView() {
        guard let onView = UIApplication.sharedApplication().keyWindow else {
            return
        }
        self.alpha = 0.0
        onView.addSubview(self)
        
        let margins = onView.layoutMarginsGuide
        self.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: -40.0).active = true
        
        self.centerXAnchor.constraintEqualToAnchor(margins.centerXAnchor).active = true
        
        self.needsUpdateConstraints()
        
        // display the view
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1.0
        }) { (finished) -> Void in
            // When finished wait 1.5 seconds, than hide it
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.hideView()
            }
        }
    }
    func closeButtonTapped(button: UIButton) {
        print("Button pressed 👍")
    }
    
    func tapped(sender: AnyObject?) {
        print("tapped")
        if let tabBarController = self.window?.rootViewController as? TabBarVC {
            tabBarController.selectedIndex = 1
        }
    }
    
}
