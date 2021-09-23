//
//  WalletAccountTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletAccountTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalAccountBalanceLabel: UILabel!
    @IBOutlet weak var spendableAccountBalanceLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var account: DcrlibwalletAccount? {
        didSet {
            self.accountNameLabel.text = account?.name
            self.totalAccountBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: account?.dcrTotalBalance, smallerTextSize: 15)
            self.spendableAccountBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: account?.dcrSpendableBalance, smallerTextSize: 14, textColor: UIColor.appColors.text4)
        }
    }
}
