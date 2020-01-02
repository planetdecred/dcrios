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

class AccountTableViewCell: UITableViewCell {

    @IBOutlet weak var accountNameLbl: UILabel!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var spendableAmountLbl: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    
    var account: DcrlibwalletAccount?
    
    func setAccount(_ account:DcrlibwalletAccount){
        self.account = account
        self.accountNameLbl.text = account.name
        self.totalAmountLbl.attributedText = Utils.getAttributedString(str: "\(account.balance?.total ?? 0)", siz: 14.0, TexthexColor: UIColor.init(hex: "0A1440"))
        self.spendableAmountLbl.text = "\(account.balance?.spendable ?? 0) DCR"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedBtn.isHidden = !selected
    }
}
