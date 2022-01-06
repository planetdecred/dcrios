//
//  WalletMixerCell.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

open class WalletMixerCell: UITableViewCell {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var balenceTitleLabel: UILabel!
    @IBOutlet weak var balanceValueLabel: UILabel!
    
    static let height: CGFloat = 80
    
    class var walletMixerIdentifier: String {
        return "\(self)"
    }
    
    override open func awakeFromNib() {
        let attribute = self.semanticContentAttribute
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: attribute)
        if layoutDirection == .rightToLeft {
            balanceValueLabel.textAlignment = .left
        }
    }
    
    func render(_ walletName: String, balance: String) {
        self.walletNameLabel.text = walletName
        self.balanceValueLabel.text = balance
    }
}
