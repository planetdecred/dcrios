//  TransactionOverviewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class TransactionOverviewCell: UITableViewCell {
    @IBOutlet weak var txIconImageView: UIImageView!
    @IBOutlet weak var txAmountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var confirmationsLabel: UILabel!
    
    func setup(_ transaction: Transaction) {
        let attributedAmountString = NSMutableAttributedString(string: (transaction.type == DcrlibwalletTxTypeRegular && transaction.direction == DcrlibwalletTxDirectionSent) ? "-" : "")
        attributedAmountString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 20.0, TexthexColor: UIColor.appColors.darkBlue))
        self.txAmountLabel.attributedText = attributedAmountString

        self.dateLabel.text = Utils.formatDateTime(timestamp: transaction.timestamp)

        let txConfirmations = transaction.confirmations
        if Settings.spendUnconfirmed || txConfirmations > 1 {
            self.statusImageView.image = UIImage(named: "ic_confirmed")
            self.statusLabel.text = LocalizedStrings.confirmed
            self.statusLabel.textColor = UIColor.appColors.green
            self.confirmationsLabel.text = " · " + String(format: LocalizedStrings.confirmations, txConfirmations)
        } else {
            self.statusImageView.image = UIImage(named: "ic_pending")
            self.statusLabel.text = LocalizedStrings.pending
            self.statusLabel.textColor = UIColor.appColors.lightBluishGray
            self.confirmationsLabel.text = ""
        }

        if transaction.type == DcrlibwalletTxTypeRegular {
            self.displayRegularTxInfo(transaction)
        } else if transaction.type == DcrlibwalletTxTypeVote {
            self.displayVoteTxInfo(transaction)
        } else if transaction.type == DcrlibwalletTxTypeTicketPurchase {
            self.displayTicketPurchaseInfo(transaction)
        }
    }
    
    func displayRegularTxInfo(_ transaction: Transaction) {
        if transaction.direction == DcrlibwalletTxDirectionSent {
            self.txIconImageView.image = UIImage(named: "ic_send")
        } else if transaction.direction == DcrlibwalletTxDirectionReceived {
            self.txIconImageView.image = UIImage(named: "ic_receive")
        } else if transaction.direction == DcrlibwalletTxDirectionTransferred {
            self.txIconImageView.image = UIImage(named: "ic_fee")
        }
    }

    func displayTicketPurchaseInfo(_ transaction: Transaction) {
        self.txIconImageView.image =  UIImage(named: "ic_ticketVoted")
    }

    func displayVoteTxInfo(_ transaction: Transaction) {
        self.txIconImageView.image =  UIImage(named: "ic_ticketImmature")

        let txConfirmations = transaction.confirmations
        let requiredConfirmations = Settings.spendUnconfirmed ? 0 : 2

        if txConfirmations < requiredConfirmations {
            self.statusImageView.image = UIImage(named: "ic_pending")
            self.statusLabel.text = LocalizedStrings.pending
            self.statusLabel.textColor = UIColor.appColors.lightBluishGray
            self.confirmationsLabel.text = ""
        } else if txConfirmations > BuildConfig.TicketMaturity {
            self.txIconImageView.image = UIImage(named: "ic_ticketLive")
        } else {
            self.txIconImageView.image = UIImage(named: "ic_ticketImmature")
        }
    }
}
