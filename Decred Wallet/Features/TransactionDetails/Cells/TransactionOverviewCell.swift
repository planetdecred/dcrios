//  TransactionOverviewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

struct TransactionOverView {
    var txIconImage: UIImage?
    var txAmount: NSMutableAttributedString?
    var date: String?
    var status: String?
    var statusLabelColor: UIColor?
    var statusImage: UIImage?
    var confirmations: String?
}

class TransactionOverviewCell: UITableViewCell {
    @IBOutlet weak var txIconImageView: UIImageView!
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var confirmationsLabel: UILabel!

    func display(_ txOverView: TransactionOverView) {
        self.txIconImageView.image = txOverView.txIconImage
        self.txAmountLabel.attributedText = txOverView.txAmount
        self.dateLabel.text = txOverView.date
        self.statusLabel.text = txOverView.status
        self.statusLabel.textColor = txOverView.statusLabelColor
        self.statusImageView.image = txOverView.statusImage
        self.confirmationsLabel.text = txOverView.confirmations
    }
}
