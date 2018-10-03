//
//  TransactionHistoryTableViewCell.swift
//  Decred Wallet
//
//  Created by rails on 23/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

//
//  TransactionHistoryTableViewCell.swift
//  Decred Wallet
//
//  Created by rails on 23/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

struct TransactionTableViewCellData {
    
    init(data: Transaction) {
        self.trans = data
        
    }
     var trans: Transaction
    /*var trStatus: String
    var trType: String
    var trAmount: String
    var trDate: String*/
}

class TransactionHistoryTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var trImage: UIImageView!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtTrStatus: UILabel!

    
    override func awakeFromNib() {
    }
    
    override class func height() -> CGFloat {
        return 80
    }
    
    override func setData(_ data: Any?) {
        if let data = data as? TransactionTableViewCellData {
            
            let confirmation =  SingleInstance.shared.wallet?.getBestBlock()
            let confirm2 = (confirmation)! - Int32(data.trans.Height)
            print("am in here")
            if(confirm2 == -1){
                self.txtTrStatus.textColor = UIColor(hex:"#3d659c")
                self.txtTrStatus.text = "Pending"
            }
            else{
                if(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") || confirm2 > 1){
                    
                    self.txtTrStatus.textColor = UIColor(hex:"#55bb97")
                    self.txtTrStatus.text = "Confirmed"
                }
                else{
                    self.txtTrStatus.textColor = UIColor(hex:"#3d659c")
                    self.txtTrStatus.text = "Pending"
                }
            }
            let Date2 = NSDate.init(timeIntervalSince1970: TimeInterval(data.trans.Timestamp) )
            let dateformater = DateFormatter()
            dateformater.dateFormat = "yyyy-MM-dd hh:mm"
            dateformater.string(from: Date2 as Date)
            self.txtDate.text = dateformater.string(from: Date2 as Date)
            
            if(data.trans.Direction == 0){
                self.txtAmount.attributedText = getAttributedString(str: "-".appending(Decimal(data.trans.Amount / 100000000.00).description))
                print("deduction")
                print(data.trans.Amount)
                let num = Decimal(data.trans.Amount) / 100000000
                print(Double(num.description)!)
                self.trImage?.image = UIImage(named: "debit")
            }
            else if(data.trans.Direction == 1){
                self.txtAmount.attributedText = getAttributedString(str: Decimal(data.trans.Amount / 100000000.00).description)
                self.trImage?.image = UIImage(named: "credit")
                print(data.trans.Amount)
                let num = Decimal(data.trans.Amount) / 100000000
                print(Double(num.description)!)
            }
            else if(data.trans.Direction == 2){
                self.txtAmount.attributedText = getAttributedString(str: (data.trans.Amount / 100000000.00).description)
                self.trImage?.image = UIImage(named: "account")
                print(data.trans.Amount)
                let num = Decimal(data.trans.Amount) / 100000000
                print(Double(num.description)!)
            }
            if(data.trans.Type == "vote"){
                self.txtAmount.text = "Vote"
            }
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

