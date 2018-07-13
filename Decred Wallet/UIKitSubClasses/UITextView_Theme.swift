//  UITextView_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UITextView_Theme: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
        textColor = AppDelegate.shared.theme.defaultTextColor
        subscribeToThemeUpdates()
    }
    
    override func changeSkin() {
        super.changeSkin()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
        textColor = AppDelegate.shared.theme.defaultTextColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
