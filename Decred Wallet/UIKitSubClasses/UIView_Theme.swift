///  UIView_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UIView_Theme: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
