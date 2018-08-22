//  AccountsHeaderView.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class AccountsHeaderView: UIView {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelTotalBalance: UILabel!
    @IBOutlet private weak var labelSpendableBalance: UILabel!
    @IBOutlet private weak var viewHighLight: UIView!
    
    var headerIndex: Int = 0
    
//    var exapndOrCollapse: ((Int) -> Void)?
    
    var totalBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async {
                self.labelTotalBalance.text = "\(newValue)"
            }
            
        }
    }
    
    @IBAction func expnandOrCollapseAction(_ sender: UIButton) {
        DispatchQueue.main.async {
//            self.exapndOrCollapse?(self.headerIndex)
        }
    }
    
    var spendableBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async {
            self.labelSpendableBalance.text = "\(newValue)"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("header view initializing")
        // Initialization code
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
            DispatchQueue.main.async {
            self.labelTitle.text = newValue
            }
        }
    }

}
