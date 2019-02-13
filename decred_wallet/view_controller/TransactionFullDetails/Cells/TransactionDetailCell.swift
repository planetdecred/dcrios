//  TransactionDetailCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class TransactionDetailCell: UITableViewCell {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelValue: UILabel!
    
    var txnDetails: TransactionDetails? {
        didSet {
            showData()
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
    
    private func showData() {
        guard let txn = self.txnDetails else { return }
        
        self.labelTitle.text = txn.title
        self.labelValue.attributedText = txn.value
        self.labelValue.textColor = txn.textColor
    }
}
