//  AccountDataCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class AccountDataCell: UITableViewCell {
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelTotalBalance: UILabel!
    @IBOutlet private weak var labelSpendableBalance: UILabel!
    @IBOutlet private weak var viewHighLight: UIView!
    
    var totalBalance: Double = 0.0 {
        willSet {
            self.labelTotalBalance.text = "\(newValue)"
        }
    }
    
    var spendableBalance: Double = 0.0 {
        willSet {
            self.labelSpendableBalance.text = "\(newValue)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var hightLithColor: UIColor? {
        get {
            return viewHighLight.backgroundColor
        }
        
        set {
            viewHighLight.backgroundColor = newValue
        }
    }
    
    var title: String? {
        get {
            return labelTitle.text
        }
        
        set {
            labelTitle.text = newValue
        }
    }
}
