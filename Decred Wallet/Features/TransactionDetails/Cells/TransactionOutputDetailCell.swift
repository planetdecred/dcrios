//
//  TransactionOutputDetailCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactionOutputDetailCell: UITableViewCell {
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var txHashLabel: UILabel!
    var onTxHashCopied: (() -> ())?

    func setup(_ output: TxOutput) {
        var amount = Utils.getAttributedString(str: "\(output.dcrAmount.round(8))", siz: 13, TexthexColor: UIColor.appColors.darkBlue)
        var address = output.address

        var account = output.accountNumber >= 0 ? output.accountName: LocalizedStrings.external.lowercased()
        account = " (\(account))"

        switch output.scriptType {
        case "nulldata":
            amount = NSAttributedString(string: "[\(LocalizedStrings.nullData)]")
            address = "[\(LocalizedStrings.script)]"
            account = ""
        case "stakegen":
            address = "[\(LocalizedStrings.stakegen)]"
        default:
        break
        }

        self.txAmountLabel.text = amount.string + account
        self.txHashLabel.text = address

        self.txHashLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(txHashLabelTapped)
        )
        self.txHashLabel.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func txHashLabelTapped(_ sender: UITapGestureRecognizer?) {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.txHashLabel.text
            self.onTxHashCopied?()
        }
    }
}
