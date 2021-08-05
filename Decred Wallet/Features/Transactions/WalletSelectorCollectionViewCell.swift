//
//  WalletSelectorCollectionViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class WalletSelectorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    override var isSelected: Bool {
        didSet {
            self.walletNameLabel.textColor = isSelected ? UIColor.appColors.primary : UIColor.appColors.text4
            self.indicatorView.isHidden = !isSelected
        }
    }
}
