//  UILabel_DimColor.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UILabel_DimColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
    }
    
    override func changeSkin() {
        super.changeSkin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:-
class UILabel_DefaultTextColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
    }
    
    override func changeSkin() {
        super.changeSkin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:-
class UILabel_GreenColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
    }
    
    override func changeSkin() {
        super.changeSkin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:-
class UILabel_BlueColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
    }
    
    override func changeSkin() {
        super.changeSkin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:-
class UILabel_AccountDetails: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
    }
    
    override func changeSkin() {
        super.changeSkin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:-
class UILabel_WhiteColor: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeToThemeUpdates()
    }
    
    override func changeSkin() {
        super.changeSkin()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
