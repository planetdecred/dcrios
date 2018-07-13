//  UIButton_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UIButton_Theme: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
