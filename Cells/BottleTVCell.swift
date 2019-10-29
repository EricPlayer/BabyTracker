//
//  BottleTVCell.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/17.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class BottleTVCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var bottleButton: UIButton!
    @IBOutlet weak var actId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
