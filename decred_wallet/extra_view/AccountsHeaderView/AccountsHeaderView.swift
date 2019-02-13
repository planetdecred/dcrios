//  AccountsHeaderView.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class AccountsHeaderView: UIView {
    
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelTotalBalance: UILabel!
    @IBOutlet private var labelSpendableBalance: UILabel!
    @IBOutlet var expandOrCollapseDetailsButton: UIButton!
    @IBOutlet weak var arrowDirection: UIButton!
    
    var headerIndex: Int = 0
    var arrobool = false
    
    var totalBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.labelTotalBalance.attributedText = getAttributedString(str: "\(newValue)", siz: 13.0)
            }
        }
    }
    
    @IBAction func expnandOrCollapseAction(_ sender: UIButton) {}
    
    var spendableBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async {
                self.labelSpendableBalance.text = "\(newValue)".appending("DCR")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var title: String? {
        get {
            return labelTitle.text
        }
        set {
            DispatchQueue.main.async {
                self.labelTitle.text = newValue
            }
        }
    }
}
