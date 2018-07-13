//  UILabel_DimColor.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UILabel_DimColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
    }

    override func changeSkin() {
        super.changeSkin()
        textColor = AppDelegate.shared.theme.dimTextColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -

class UILabel_DefaultTextColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
    }

    override func changeSkin() {
        super.changeSkin()
        textColor = AppDelegate.shared.theme.defaultTextColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -

class UILabel_GreenColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
    }

    override func changeSkin() {
        super.changeSkin()
        textColor = AppDelegate.shared.theme.greenTextColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -

class UILabel_BlueColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
    }

    override func changeSkin() {
        super.changeSkin()
        textColor = AppDelegate.shared.theme.blueTextColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -

class UILabel_AccountDetails: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
    }

    override func changeSkin() {
        super.changeSkin()
        textColor = AppDelegate.shared.theme.accountDetailsTextColor
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: -

class UILabel_WhiteColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
    }

    override func changeSkin() {
        super.changeSkin()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
