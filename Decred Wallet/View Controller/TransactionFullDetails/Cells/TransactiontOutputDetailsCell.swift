//  TransactiontOutputDetailsTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class TransactiontOutputDetailsCell: UITableViewCell_Theme {
    @IBOutlet private weak var viewContainer: UIView_Theme!
    
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
        self.viewContainer.isHidden.toggle()
        expandOrCollapse?()
    }
    
}
