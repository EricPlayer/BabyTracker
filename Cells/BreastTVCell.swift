//
//  BreastTVCell.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/17.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class BreastTVCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var bLeftLabel: UILabel!
    @IBOutlet weak var bLeftView: UIView!
    @IBOutlet weak var bLeftButton: UIButton!
    @IBOutlet weak var bRightLabel: UILabel!
    @IBOutlet weak var bRightView: UIView!
    @IBOutlet weak var bRightButton: UIButton!
    @IBOutlet weak var actId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
