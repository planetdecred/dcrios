//
//  Button.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 30/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

@IBDesignable
class Button: UIButton {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    override init(frame: CGRect) {
        cornerRadius = 0
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        cornerRadius = 0
        super.init(coder: aDecoder)
    }
}
