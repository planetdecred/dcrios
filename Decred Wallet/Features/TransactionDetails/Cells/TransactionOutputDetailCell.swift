//
//  TransactionOutputDetailCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class TransactionOutputDetailCell: UITableViewCell {
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var txHashButton: UIButton!
    var onTxHashCopied: (() -> ())?

    func display(_ output: TxOutput, wallet: DcrlibwalletWallet) {
        var amount = Utils.getAttributedString(str: "\(output.dcrAmount.round(8))", siz: 13, TexthexColor: UIColor.appColors.darkBlue)
        var address = output.address
        var error: NSError?
        let accountName = wallet.accountName(output.accountNumber, error: &error)
        
        if error != nil {
            Utils.showBanner(in: contentView, type: .error, text: error!.localizedDescription)
        }

        var account = output.accountNumber >= 0 ? accountName: LocalizedStrings.external.lowercased()
        account = " (\(account))"

        switch output.scriptType {
        case "nulldata":
            amount = NSMutableAttributedString(string: "[\(LocalizedStrings.nullData)]")
            address = "[\(LocalizedStrings.script)]"
            account = ""
        case "stakegen":
            address = "[\(LocalizedStrings.stakegen)]"
        default:
        break
        }

        self.txAmountLabel.text = amount.string + account
        self.txHashButton.setTitle(address, for: .normal)
    }

    @IBAction func txHashButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            UIPasteboard.general.string = (sender as! UIButton).titleLabel!.text
            self.onTxHashCopied?()
        }
    }
}
