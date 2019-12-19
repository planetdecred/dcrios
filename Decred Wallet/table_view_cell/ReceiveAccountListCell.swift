//
//  ReceiveAccountListCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
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
