//  TransactionDetailCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

struct TransactionDetails {
    let title: String
    let value: NSAttributedString
    let isCopyEnabled: Bool
}

class TransactionDetailCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueButton: UIButton!
    var presentingController: TransactionDetailsViewController?
    
    var txnDetails: TransactionDetails? {
        didSet {
            showData()
        }
    }

    @IBAction func onValueButtonClicked(_ sender: Any) {
        if let txn = self.txnDetails,
            txn.isCopyEnabled,
            let presentingController = self.presentingController {
            DispatchQueue.main.async {
                //Copy a string to the pasteboard.
                UIPasteboard.general.string = txn.value.string
                Utils.showBanner(parentVC: presentingController, type: .success, text: LocalizedStrings.copied)
            }
        }
    }

    private func showData() {
        guard let txn = self.txnDetails else { return }

        self.titleLabel.text = txn.title
        self.valueButton.setTitle(txn.value.string, for: .normal)
        self.valueButton.setTitleColor(txn.isCopyEnabled ? UIColor.appColors.lightBlue : UIColor.appColors.darkBlue, for: .normal)
        self.isUserInteractionEnabled = txn.isCopyEnabled
    }
}
