//  UITableView_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

open class UITableViewCell_Theme: UITableViewCell {
    override open func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
        contentView.backgroundColor = AppDelegate.shared.theme.backgroundColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


class UITableView_Theme: UITableView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
