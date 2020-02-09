//
//  TransactionOutputDetailCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactionOutputDetailCell: UITableViewCell {
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var txHashLabel: UILabel!

    func setup(_ output: TxOutput) {
        var amount = Utils.getAttributedString(str: "\(output.dcrAmount.round(8))", siz: 13, TexthexColor: UIColor.appColors.darkBlue)
        var address = output.address

        var title = output.accountNumber >= 0 ? output.accountName: LocalizedStrings.external.lowercased()
        title = " (\(title))"

        switch output.scriptType {
        case "nulldata":
            amount = NSAttributedString(string: "[\(LocalizedStrings.nullData)]")
            address = "[\(LocalizedStrings.script)]"
            title = ""
        case "stakegen":
            address = "[\(LocalizedStrings.stakegen)]"
        default:
        break
        }

        self.txAmountLabel.text = amount.string + title
        self.txHashLabel.text = address
    }
}
