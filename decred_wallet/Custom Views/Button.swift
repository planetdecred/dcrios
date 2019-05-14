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
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.setNeedsLayout()
        }
    }
}
