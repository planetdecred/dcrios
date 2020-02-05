//
//  WalletAccountSelectorTableViewCell.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 02/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit
import Dcrlibwallet

class WalletAccountSelectorTableViewCell: UITableViewCell {
    var wallet: DcrlibwalletAccount?
    
    @IBOutlet var amountSpendable: UILabel!
    @IBOutlet var amountInWallet: UILabel!
    @IBOutlet var accountName: UILabel!
    
    func configure(with account: DcrlibwalletAccount) {
        wallet = account
        accountName.text = account.name
        let amountInWalletText = (Decimal(account.balance!.dcrTotal) as NSDecimalNumber).round(8).formattedWithSeparator
        amountInWallet.text = "\(amountInWalletText)"
        let spendableAmountText = (Decimal(account.balance!.dcrSpendable) as NSDecimalNumber).round(8).formattedWithSeparator
        amountSpendable.text = "\(spendableAmountText)"
    }
}
