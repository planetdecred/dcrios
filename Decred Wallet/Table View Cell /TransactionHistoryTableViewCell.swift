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
    
    init(data: Dictionary<String, String>) {
        self.trStatus = data["status"]!
        self.trType = data["type"]!
        self.trAmount = data["amount"]!
        self.trDate = data["date"]!
        
    }
    var trStatus: String
    var trType: String
    var trAmount: String
    var trDate: String
}

class TransactionHistoryTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var trImage: UIImageView!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtTrStatus: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
        contentView.backgroundColor = AppDelegate.shared.theme.backgroundColor
    }
    
    override class func height() -> CGFloat {
        return 80
    }
    
    override func setData(_ data: Any?) {
        if let data = data as? TransactionTableViewCellData {
            
            self.txtAmount.attributedText = self.getAttributedString(str: data.trAmount)
            self.txtDate.text = data.trDate
            self.txtTrStatus.text = data.trStatus
            
            if(data.trType == "Debit"){
                self.trImage?.image = UIImage(named: "debit")
            }
            else{
                self.trImage?.image = UIImage(named: "credit")
            }
            
            if(data.trStatus == "Confirmed"){
                self.txtTrStatus?.textColor = UIColor(red: 102.0/255.0, green: 187.0/255.0, blue: 171.0/255.0, alpha: 1.0)
            }
            else{
                self.txtTrStatus?.textColor = UIColor(red: 60.0/255.0, green: 130.0/255.0, blue: 184.0/255.0, alpha: 1.0)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func getAttributedString(str: String) -> NSAttributedString {
        
        let stt = str as NSString!
        let atrStr = NSMutableAttributedString(string: stt! as String)
        let dotRange = stt?.range(of: ".")
        //print("Index = \(dotRange?.location)")
        if(str.length > ((dotRange?.location)!+2)) {
            atrStr.addAttribute(NSAttributedStringKey.font,
                                         value: UIFont(
                                            name: "AmericanTypewriter",
                                            size: 11.0)!,
                                         range: NSRange(
                                            location:(dotRange?.location)!+3,
                                            length:(stt?.length)!-1 - ((dotRange?.location)!+2)))
            
            atrStr.addAttribute(NSAttributedStringKey.foregroundColor,
                                value: UIColor.lightGray,
                                range: NSRange(
                                    location:(dotRange?.location)!+3,
                                    length:((stt?.length)!-1) - ((dotRange?.location)!+2)))
            
        }
        return atrStr
    }
    
}

