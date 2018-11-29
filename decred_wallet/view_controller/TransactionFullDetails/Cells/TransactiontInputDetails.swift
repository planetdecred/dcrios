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
        let _ = debitsStack.arrangedSubviews.map({self.debitsStack.removeArrangedSubview($0)})
        debits.forEach { (debit) in
            self.addSubrow(with: debit)
        }
        alcDebitStackHeight.constant = CGFloat(45 * debits.count)
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewCotainer.isHidden = !self.viewCotainer.isHidden
        expandOrCollapse?()
    }
    
    private func addSubrow(with debit: Debit){
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width:self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        let accountNameLabel = UILabel(frame: CGRect(x:5.0, y:23.0, width:self.frame.size.width, height: 22.0))
        accountNameLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        subrow.addSubview(amountLabel)
        subrow.addSubview(accountNameLabel)
        amountLabel.text = "\(debit.dcrAmount)"
        accountNameLabel.text = debit.AccountName
        debitsStack.addArrangedSubview(subrow)
    }
}

