//
//  UnderlineTextField.swift
//  BabyTracker
//
//  Created by Eric on 2019/10/19.
//  Copyright © 2019 fatih. All rights reserved.
//

import UIKit

class UnderlineTextField: UITextField {
        
    let border = CALayer()
    
    @IBInspectable open var lineColor : UIColor = UIColor.lightGray {
        didSet{
            border.borderColor = lineColor.cgColor
        }
    }
    
    @IBInspectable open var selectedLineColor : UIColor = UIColor.darkGray {
        didSet{
        }
    }
    
    
    @IBInspectable open var lineHeight : CGFloat = CGFloat(1.0) {
        didSet{
            border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        }
    }
    
    required init?(coder aDecoder: (NSCoder?)) {
        super.init(coder: aDecoder!)
        border.borderColor = lineColor.cgColor
//        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = lineHeight
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        border.frame = CGRect(x: 0, y: self.frame.size.height - lineHeight, width:  self.frame.size.width, height: self.frame.size.height)
    }
}
