//
//  ReceiveAccountListCell.swift
//  Decred Wallet
//
//  Created by HXMacMini on 2019/12/2.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit
import Dcrlibwallet

class ReceiveAccountListCell: UITableViewCell {

    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var totalLab: UILabel!
    @IBOutlet weak var spendable: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    
    var account: DcrlibwalletAccount?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setAccount(account:DcrlibwalletAccount){
        
        self.account = account
        
        self.nameLab.text = account.name
        
        let total = "\(account.balance?.total ?? 0)"
        let length:Int = total.length>4 ? 4:total.length
        let totalStr = total + " DCR"
        let attr:NSMutableAttributedString = NSMutableAttributedString.init(string: totalStr)
        attr.addAttributes([NSMutableAttributedString.Key.font:UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: length))
        self.totalLab.attributedText = attr

        self.spendable.text = "\(account.balance?.spendable ?? 0) DCR"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.selectedBtn.isHidden = !selected
    }
    
}
