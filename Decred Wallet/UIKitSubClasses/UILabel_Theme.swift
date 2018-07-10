//  UILabel_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UILabel_Theme: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
             self.textColor = AppDelegate.shared.theme.textColor
        self.backgroundColor = UIColor.orange
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
