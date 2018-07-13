//  UILabel_DimColor.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UILabelDimColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
        textColor = AppDelegate.shared.theme.dimTextColor
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

class UILabelDefaultTextColor: UILabel {
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

class UILabelGreenColor: UILabel {
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

class UILabelBlueColor: UILabel {
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

class UILabelAccountDetails: UILabel {
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

class UILabelWhiteColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
        changeSkin()
    }

    override func changeSkin() {
        super.changeSkin()
        textColor = AppDelegate.shared.theme.white
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
