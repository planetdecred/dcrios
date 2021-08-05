//
//  AccountSelectorTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class AccountSelectorTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalAccountBalanceLabel: UILabel!
    @IBOutlet weak var spendableAccountBalanceLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!

    var account: DcrlibwalletAccount? {
        didSet {
            self.accountNameLabel.text = account?.name
            self.spendableAccountBalanceLabel.text = "\(account?.dcrSpendableBalance ?? 0) DCR"

            let totalBalance = account?.dcrTotalBalance ?? 0
            let totalBalanceRoundedOff = (Decimal(totalBalance) as NSDecimalNumber).round(8)
            self.totalAccountBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalBalanceRoundedOff)", siz: 15.0, TexthexColor: UIColor.appColors.text1)
        }
    }
}
