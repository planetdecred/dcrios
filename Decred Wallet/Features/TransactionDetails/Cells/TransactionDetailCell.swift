//  TransactionDetailCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

struct TransactionDetail {
    let title: String
    let value: String
    let isCopyEnabled: Bool
}

class TransactionDetailCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueButton: UIButton!

    var onTxDetailValueCopied: ((_ copiedDetail: String) -> ())?
    var txDetail: TransactionDetail? {
        didSet {
            showData()
        }
    }

    private func showData() {
        guard let tx = self.txDetail else { return }

        self.titleLabel.text = tx.title
        self.valueButton.setTitle(tx.value, for: .normal)
        self.valueButton.setTitleColor(tx.isCopyEnabled ? UIColor.appColors.lightBlue : UIColor.appColors.darkBlue, for: .normal)
        self.isUserInteractionEnabled = tx.isCopyEnabled
    }

    @IBAction func onValueButtonTapped(_ sender: Any) {
        guard let tx = self.txDetail, tx.isCopyEnabled else {
            return
        }
        DispatchQueue.main.async {
            UIPasteboard.general.string = tx.value
            self.onTxDetailValueCopied?(tx.title)
        }
    }
}
