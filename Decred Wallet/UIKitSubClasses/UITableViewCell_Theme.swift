//  UITableViewCell_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

open class UITableViewCell_Theme: UITableViewCell {

    open override func awakeFromNib() {
        super.awakeFromNib()
//        backgroundColor = AppDelegate.shared.theme.backgroundColor
        contentView.backgroundColor = AppDelegate.shared.theme.backgroundColor
        subscribeToThemeUpdates()
    }
    
    override open func  setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
