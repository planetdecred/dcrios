//  TransactionInputDetailCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactionInputDetailCell: UITableViewCell {
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var txHashButton: UIButton!
    
    var onTxHashCopied: (() -> ())?
    
    func display(_ input: TxInput) {
        self.txAmountLabel.text = Utils.getAttributedString(str: "\(input.dcrAmount.round(8))", siz: 16, TexthexColor: UIColor.appColors.darkBlue).string
            + " (\(input.accountNumber))"

        var hash = input.previousTransactionHash
        if hash == "0000000000000000000000000000000000000000000000000000000000000000" {
            hash = "Stakebase: 0000"
        }
        hash = "\(hash):\(input.previousTransactionIndex)"
        self.txHashButton.setTitle(hash, for: .normal)
    }
    
    @IBAction func txHashButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            UIPasteboard.general.string = (sender as! UIButton).titleLabel!.text
            self.onTxHashCopied?()
        }
    }
}
