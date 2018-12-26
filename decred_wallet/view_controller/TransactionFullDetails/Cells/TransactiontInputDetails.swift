//  TransactiontInputDetails.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class TransactiontInputDetails: UITableViewCell {
    @IBOutlet weak var viewCotainer: UIView!
    @IBOutlet weak var debitsStack: UIStackView!
    
    @IBOutlet weak var alcDebitStackHeight: NSLayoutConstraint!
    var expandOrCollapse: (() -> Void)?

    func setup(with debits:[Debit]){
        alcDebitStackHeight.constant = CGFloat(45 * debits.count)
        let _ = debitsStack.arrangedSubviews.map({self.debitsStack.removeArrangedSubview($0)})
        debits.forEach { (debit) in
            self.addSubrow(with: debit)
        }
        
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewCotainer.isHidden = false
        expandOrCollapse?()
    }
    
    private func addSubrow(with debit: Debit){
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width:self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        let addressLabel = UILabel(frame: CGRect(x:5.0, y:23.0, width:self.frame.size.width, height: 22.0))
        
        addressLabel.textColor = #colorLiteral(red: 0.2470588235, green: 0.4941176471, blue: 0.8901960784, alpha: 1)
        subrow.addSubview(amountLabel)
        subrow.addSubview(addressLabel)
        amountLabel.text = "\(debit.dcrAmount) DCR (\(debit.AccountName))"
        amountLabel.font = amountLabel.font.withSize(15)
        debitsStack.addArrangedSubview(subrow)
    }
}

