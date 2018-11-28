//  TransactiontOutputDetailsTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class TransactiontOutputDetailsCell: UITableViewCell {
    @IBOutlet private weak var viewContainer: UIView!
    
    var expandOrCollapse: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewContainer.isHidden.toggles()
        expandOrCollapse?()
    }
    
}
