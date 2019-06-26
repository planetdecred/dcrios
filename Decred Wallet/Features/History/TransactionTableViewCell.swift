//
//  TransactionTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class TransactionTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var dateT: UILabel!
    
    var count = 0
    
    override func awakeFromNib() {}
    
    override class func height() -> CGFloat {
        return 60
    }
    
    override func setData(_ data: Any?) {
        
        if let transaction = data as? Transaction {
            let bestBlock =  AppDelegate.walletLoader.wallet?.getBestBlock()
            var confirmations = 0
            if(transaction.Height != -1){
                confirmations = Int(bestBlock!) - transaction.Height
                confirmations += 1
            }

            if (transaction.Height == -1) {
                self.status.textColor = UIColor(hex:"#3d659c")
                self.status.text = LocalizedStrings.pending
            } else {
                if (Settings.spendUnconfirmed || confirmations > 1) {
                    self.status.textColor = UIColor(hex:"#2DD8A3")
                    self.status.text = LocalizedStrings.confirmed
                } else {
                    self.status.textColor = UIColor(hex:"#3d659c")
                    self.status.text = LocalizedStrings.pending
                }
            }
            
            let Date2 = NSDate.init(timeIntervalSince1970: TimeInterval(transaction.Timestamp) )
            let dateformater = DateFormatter()
            dateformater.locale = Locale(identifier: "en_US_POSIX")
            dateformater.dateFormat = "MMM dd, yyyy hh:mma"
            dateformater.amSymbol = "am"
            dateformater.pmSymbol = "pm"
            dateformater.string(from: Date2 as Date)
            
            self.dateT.text = dateformater.string(from: Date2 as Date)
            let amount = Decimal(transaction.Amount / 100000000.00) as NSDecimalNumber
            let requireConfirmation = Settings.spendUnconfirmed ? 0 : 2
            
            if (transaction.Type.lowercased() == "regular") {
                if (transaction.Direction == 0) {
                    let attributedString = NSMutableAttributedString(string: "-")
                    attributedString.append(Utils.getAttributedString(str: amount.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "debit")
                } else if(transaction.Direction == 1) {
                    let attributedString = NSMutableAttributedString(string: " ")
                    attributedString.append(Utils.getAttributedString(str: amount.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "credit")
                } else if(transaction.Direction == 2) {
                    let attributedString = NSMutableAttributedString(string: " ")
                    attributedString.append(Utils.getAttributedString(str: amount.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "account")
                }
            } else if(transaction.Type.lowercased() == "vote") {
                self.dataText.text = " \(LocalizedStrings.vote)"
                self.dataImage?.image = UIImage(named: "vote")
            } else if (transaction.Type.lowercased() == "ticket_purchase") {
                self.dataText.text = " \(LocalizedStrings.ticket)"
                self.dataImage?.image = UIImage(named: "immature")
                if (confirmations < requireConfirmation){
                    self.status.textColor = UIColor(hex:"#3d659c")
                    self.status.text = LocalizedStrings.pending
                } else if (confirmations > BuildConfig.TicketMaturity) {
                    let statusText = LocalizedStrings.confirmedLive
                    let range = (statusText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: statusText)
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
                    self.status.textColor = UIColor(hex:"#2DD8A3")
                    self.status.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "live")
                } else {
                    let statusText = LocalizedStrings.confirmedImmature
                    let range = (statusText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: statusText)
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)

                    self.status.textColor = UIColor.orange
                    self.status.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "immature")
                }
            }
        }
    }
}
