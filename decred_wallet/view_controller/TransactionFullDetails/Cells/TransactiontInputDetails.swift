//  TransactiontInputDetails.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class TransactiontInputDetails: UITableViewCell {
    @IBOutlet weak var viewCotainer: UIView!
    
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
        //self.viewCotainer.isHidden.toggle()
        expandOrCollapse?()
    }
}
