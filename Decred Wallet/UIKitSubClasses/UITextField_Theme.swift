//  UITextField_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UITextField_Theme: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppDelegate.shared.theme.backgroundColor
    }
}
