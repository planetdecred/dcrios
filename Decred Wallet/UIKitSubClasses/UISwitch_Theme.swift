//  UISwitch_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UISwitch_Theme: UISwitch {
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
