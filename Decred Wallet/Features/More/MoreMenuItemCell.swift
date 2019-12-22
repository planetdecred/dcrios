//
//  MoreMenuItemCell.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

open class MoreMenuItemCell: UITableViewCell {
    @IBOutlet weak var moreMenuIconImageView: UIImageView!
    @IBOutlet weak var moreMenuTitleLabel: UILabel!
    @IBOutlet weak var moreMenuBackground: UIView!
    
    static let height: CGFloat = 68
    
    class var morMenuIdentifier: String {
        return "\(self)"
    }
    override open func awakeFromNib() {
        self.moreMenuBackground.layer.cornerRadius = 14
    }
    
    func render(_ menuItem: MoreMenuItem) {
        self.moreMenuTitleLabel.text = menuItem.rawValue
        self.moreMenuIconImageView.image = menuItem.icon
    }
}
