//
//  DataTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

struct DataTableViewCellData {
    
    init(trans: Transaction) {
        self.trans = trans
        
    }
    var trans: Transaction
}

class DataTableViewCell : BaseTableViewCell {
    
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var dateT: UILabel!
    var count = 0
    
    override func awakeFromNib() {
            }
    
    override class func height() -> CGFloat {
        return 60
    }
    
    override func setData(_ data: Any?) {
        if let data = data as? DataTableViewCellData {
            //self.dataImage.setRandomDownloadImage(80, height: 80)
            let confirmation =  SingleInstance.shared.wallet?.getBestBlock()
            let confirm2 = (confirmation)! - Int32(data.trans.Height)
            
            print("am in here")
            print(self.count += 1)
            if(confirm2 == -1){
                self.status.textColor = UIColor(hex:"#3d659c")
                self.status.text = "Pending"
                print("pending")
            }
            else{
                if(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") || confirm2 > 1){
                    
                    self.status.textColor = UIColor(hex:"#2DD8A3")
                    self.status.text = "Confirmed"
                }
                else{
                    self.status.textColor = UIColor(hex:"#2970FF")
                    self.status.text = "Pending"
                }
            }
            let Date2 = NSDate.init(timeIntervalSince1970: TimeInterval(data.trans.Timestamp) )
            let dateformater = DateFormatter()
            dateformater.locale = Locale(identifier: "en_US_POSIX")
            dateformater.dateFormat = "MMM dd, yyyy h:mm:ss a"
            dateformater.amSymbol = "AM"
            dateformater.pmSymbol = "PM"
            dateformater.string(from: Date2 as Date)
            self.dateT.text = dateformater.string(from: Date2 as Date)
            
            if(data.trans.Direction == 0){
                self.dataText.attributedText = getAttributedString(str: "-".appending(Decimal(data.trans.Amount / 100000000.00).description))
                print("deduction")
                print(data.trans.Amount)
                let num = Decimal(data.trans.Amount) / 100000000
                print(Double(num.description)!)
                self.dataImage?.image = UIImage(named: "debit")
            }
            else if(data.trans.Direction == 1){
                 self.dataText.attributedText = getAttributedString(str: Decimal(data.trans.Amount / 100000000.00).description)
                self.dataImage?.image = UIImage(named: "credit")
                 print(data.trans.Amount)
                let num = Decimal(data.trans.Amount) / 100000000
                print(Double(num.description)!)
            }
            else if(data.trans.Direction == 2){
                self.dataText.attributedText = getAttributedString(str: (data.trans.Amount / 100000000.00).description)
                self.dataImage?.image = UIImage(named: "account")
                 print(data.trans.Amount)
                let num = Decimal(data.trans.Amount) / 100000000
                print(Double(num.description)!)
            }
            if(data.trans.Type == "vote"){
                self.dataText.text = "Vote"
            }
        }
    }
}
