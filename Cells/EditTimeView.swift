//
//  EditTimeView.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/21.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class EditTimeView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var confirmButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EditTimeView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
    }
}
