//
//  TransactionTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    @IBOutlet weak var secondaryDataLabel: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var secondaryStatusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!

    var count = 0

    override func awakeFromNib() {}

    override class func height() -> CGFloat {
        return 56
    }

    func setData(_ data: Any?) {
        if let transaction = data as? Transaction {
            var confirmations: Int32 = 0
            if transaction.blockHeight != -1 {
                confirmations = WalletLoader.shared.firstWallet!.getBestBlock() - Int32(transaction.blockHeight) + 1
            }

            let Date2 = NSDate.init(timeIntervalSince1970: TimeInterval(transaction.timestamp) )
            let dateformater = DateFormatter()
            dateformater.locale = Locale(identifier: "en_US_POSIX")
            dateformater.dateFormat = "MMM dd"
            dateformater.string(from: Date2 as Date)
            let ageInDays = (Date2 as Date).daysFromNow
            var dateString = dateformater.string(from: Date2 as Date)

            if ageInDays == 0 {
                dateString = LocalizedStrings.today
            } else if ageInDays == -1 {
                dateString = LocalizedStrings.yesterday
            }

            let isConfirmed = Settings.spendUnconfirmed || confirmations > 1
            self.status.text = isConfirmed ? dateString : LocalizedStrings.pending
            self.status.textColor = isConfirmed ? UIColor.appColors.bluishGray : UIColor.appColors.lightBluishGray
            self.statusIcon.image = isConfirmed ? UIImage(named: "ic_confirmed") : UIImage(named: "ic_pending")

            let requireConfirmation = Settings.spendUnconfirmed ? 0 : 2

            self.secondaryDataLabel.isHidden = transaction.type == DcrlibwalletTxTypeRegular
            self.secondaryStatusLabel.isHidden = transaction.type == DcrlibwalletTxTypeRegular

            if transaction.type == DcrlibwalletTxTypeRegular {
                if transaction.direction == DcrlibwalletTxDirectionSent {
                    let attributedString = NSMutableAttributedString(string: "-")
                    attributedString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 13.0, TexthexColor: UIColor.appColors.darkBlue))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "ic_send")
                } else if transaction.direction == DcrlibwalletTxDirectionReceived {
                    let attributedString = NSMutableAttributedString(string: " ")
                    attributedString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 13.0, TexthexColor: UIColor.appColors.darkBlue))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "ic_receive")
                } else if transaction.direction == DcrlibwalletTxDirectionTransferred {
                    let attributedString = NSMutableAttributedString(string: " ")
                    attributedString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 13.0, TexthexColor: UIColor.appColors.darkBlue))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "ic_fee")
                }
            } else if transaction.type == DcrlibwalletTxTypeVote {
                self.dataText.text = " \(LocalizedStrings.vote)"
                self.dataImage?.image = UIImage(named: "ic_ticketVoted")

                let attributedString = NSMutableAttributedString(string: " ")
                attributedString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 11.0, TexthexColor: UIColor.appColors.lightBluishGray))
                self.secondaryDataLabel.attributedText = attributedString
                self.secondaryStatusLabel.text = String(format: LocalizedStrings.days, -ageInDays)
            } else if transaction.type == DcrlibwalletTxTypeTicketPurchase {
                self.dataText.text = " \(LocalizedStrings.ticket)"
                self.dataImage?.image = UIImage(named: "ic_ticketImmature")
                self.secondaryStatusLabel.text = String(format: LocalizedStrings.days, -ageInDays)

                let attributedString = NSMutableAttributedString(string: " ")
                attributedString.append(Utils.getAttributedString(str: transaction.dcrAmount.round(8).description, siz: 11.0, TexthexColor: UIColor.appColors.lightBluishGray))
                self.secondaryDataLabel.attributedText = attributedString

                if confirmations < requireConfirmation {
                    self.status.textColor = UIColor.appColors.lightBluishGray
                    self.status.text = LocalizedStrings.pending
                } else if confirmations > BuildConfig.TicketMaturity {
                    self.dataText.text = LocalizedStrings.live
                    self.dataImage?.image = UIImage(named: "ic_ticketLive")
                } else {
                    self.dataText.text = LocalizedStrings.immature
                    self.dataImage?.image = UIImage(named: "ic_ticketImmature")
                }
            }
        }
    }
}
