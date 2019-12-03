//
//  WalletInfoTableViewCell.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 02/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit
import Dcrlibwallet

class WalletInfoTableViewCell: UITableViewCell {
    var wallet: WalletAccount?
    
    @IBOutlet var amountSpendable: UILabel!
    @IBOutlet var amountInWallet: UILabel!
    @IBOutlet var accountName: UILabel!
    
    func configure(with account: WalletAccount) {
        wallet = account
        accountName.text = account.Name
        let amountInWalletText = (Decimal(account.Balance!.dcrTotal) as NSDecimalNumber).round(8).formattedWithSeparator
        amountInWallet.text = "\(amountInWalletText)"
        let spendableAmountText = (Decimal(account.Balance!.dcrSpendable) as NSDecimalNumber).round(8).formattedWithSeparator
        amountSpendable.text = "\(spendableAmountText)"
    }
}
