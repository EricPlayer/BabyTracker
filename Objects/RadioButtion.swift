//
//  RadioButtion.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/18.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class RadioButton: UIButton {
    // Images
    let checkedImage = UIImage(named: "radio_checked")! as UIImage
    let uncheckedImage = UIImage(named: "radio_blank")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self && !isChecked {
            isChecked = true
        }
    }
}
