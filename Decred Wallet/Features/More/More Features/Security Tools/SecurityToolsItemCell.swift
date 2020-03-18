//
//  SecurityToolsItemCell.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SecurityToolsItemCell: UITableViewCell {

    @IBOutlet weak var securityToolsIconImageView: UIImageView!
    @IBOutlet weak var securityToolsTitleLabel: UILabel!
    @IBOutlet weak var securityToolsBackground: UIView!
    
    static let height: CGFloat = 68
    
    class var securityToolsIdentifier: String {
        return "\(self)"
    }
    override open func awakeFromNib() {
        self.securityToolsBackground.layer.cornerRadius = 14
    }
    
    func render(_ menuItem: SecurityToolsItem) {
        self.securityToolsTitleLabel.text = menuItem.displayTitle
        self.securityToolsIconImageView.image = menuItem.icon
    }
}
