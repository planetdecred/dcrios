//  AccountsHeaderView.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class AccountsHeaderView: UIView {
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelTotalBalance: UILabel!
    @IBOutlet private var labelSpendableBalance: UILabel!
    @IBOutlet var expandOrCollapseDetailsButton: UIButton!
    
    var headerIndex: Int = 0
    
    // var exapndOrCollapse: ((Int) -> Void)?
    
    var totalBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                this.labelTotalBalance.attributedText = getAttributedString(str: "\(newValue)")
                //this.labelTotalBalance.text = "\(newValue)".appending("DCR")
            }
        }
    }
    
    @IBAction func expnandOrCollapseAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            // self.exapndOrCollapse?(self.headerIndex)
        }
    }
    
    var spendableBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                
                this.labelSpendableBalance.text = "\(newValue)".appending("DCR")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("header view initializing")
        // Initialization code
    }
    
   /* var hightLithColor: UIColor? {
        get {
            return viewHighLight.backgroundColor
        }
        
        set {
            viewHighLight.backgroundColor = newValue
        }
    }*/
    
    var title: String? {
        get {
            return labelTitle.text
        }
        
        set {
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                this.labelTitle.text = newValue
            }
        }
    }
}
