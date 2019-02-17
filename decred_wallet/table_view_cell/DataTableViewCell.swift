//
//  DataTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import Foundation
import UIKit

struct DataTableViewCellData {
    
    var trans: Transaction
    
    init(trans: Transaction) {
        self.trans = trans
    }
}

class DataTableViewCell : BaseTableViewCell {
    
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
        
        if let data = data as? DataTableViewCellData {
            let confirmation =  SingleInstance.shared.wallet?.getBestBlock()
            let confirm2 = (confirmation)! - Int32(data.trans.Height)
            if (confirm2 == -1) {
                self.status.textColor = UIColor(hex:"#3d659c")
                self.status.text = "Pending"
            } else {
                if (UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") || confirm2 > 1) {
                    self.status.textColor = UIColor(hex:"#2DD8A3")
                    self.status.text = "Confirmed"
                } else {
                    self.status.textColor = UIColor(hex:"#3d659c")
                    self.status.text = "Pending"
                }
            }
            
            let Date2 = NSDate.init(timeIntervalSince1970: TimeInterval(data.trans.Timestamp) )
            let dateformater = DateFormatter()
            dateformater.locale = Locale(identifier: "en_US_POSIX")
            dateformater.dateFormat = "MMM dd, yyyy hh:mma"
            dateformater.amSymbol = "am"
            dateformater.pmSymbol = "pm"
            dateformater.string(from: Date2 as Date)
            
            self.dateT.text = dateformater.string(from: Date2 as Date)
            let tnt = Decimal(data.trans.Amount / 100000000.00) as NSDecimalNumber
            var requireConfirmation = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") ? 0 : 2
            if (data.trans.Type.lowercased() == "regular".lowercased()) {
            if (data.trans.Direction == 0) {
                self.dataText.attributedText = getAttributedString(str: "-".appending(tnt.round(8).description), siz: 13.0)
                self.dataImage?.image = UIImage(named: "debit")
            } else if(data.trans.Direction == 1) {
                self.dataText.attributedText = getAttributedString(str: tnt.round(8).description, siz: 13.0)
                self.dataImage?.image = UIImage(named: "credit")
            } else if(data.trans.Direction == 2) {
                self.dataText.attributedText = getAttributedString(str: tnt.round(8).description, siz: 13.0)
                self.dataImage?.image = UIImage(named: "account")
            }
            }
            
            else if(data.trans.Type.lowercased() != "vote".lowercased()){
                self.dataText.text = "Stake"
                self.dataImage?.image = UIImage(named: "account")
            }
            else if (data.trans.Type.lowercased() == "Ticket Purchase".lowercased()) {
                self.dataText.text = "Ticket"
                self.dataImage?.image = UIImage(named: "account")
                if (confirm2 < requireConfirmation){
                    self.status.textColor = UIColor(hex:"#3d659c")
                    self.status.text = "Pending"
                }
                else if (confirm2 > 16){
                    let stausText = "Confirmed / Live"
                    let range = (stausText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: stausText)
                    attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black , range: range)
                    self.status.textColor = UIColor(hex:"#2DD8A3")
                    self.status.attributedText = attributedString
                }
                else{
                    let stausText = "Confirmed / Immature"
                    let range = (stausText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: stausText)
                    attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black , range: range)
                    self.status.textColor = UIColor.orange
                    self.status.attributedText = attributedString
                }
        }
    }
}
}
