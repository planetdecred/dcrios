//  UITextField_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UITextField_Theme: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
        textColor = AppDelegate.shared.theme.defaultTextColor
        subscribeToThemeUpdates()
    }

    override func changeSkin() {
        super.changeSkin()
        textColor = AppDelegate.shared.theme.defaultTextColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
