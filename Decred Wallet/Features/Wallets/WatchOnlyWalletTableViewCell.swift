//
//  WatchOnlyWalletTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

protocol WatchOnlyWalletTableViewCellDelegate {
    func showWatchOnlyWalletMenu(walletName: String, walletID: Int, _ sender: UIView)
}

class WatchOnlyWalletTableViewCell: UITableViewCell {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var totalAccountBalanceLabel: UILabel!
    
    var delegate: WatchOnlyWalletTableViewCellDelegate?
    
    var wallet: Wallet! {
        didSet {
            self.walletNameLabel.text = wallet?.name
            self.totalAccountBalanceLabel.text = wallet.balance
        }
    }
    
    @IBAction func walletMenuButtonTapped(_ sender: UIView) {
        print("sent menu")
        self.delegate?.showWatchOnlyWalletMenu(walletName: self.wallet.name, walletID: self.wallet.id, sender)
    }
}
