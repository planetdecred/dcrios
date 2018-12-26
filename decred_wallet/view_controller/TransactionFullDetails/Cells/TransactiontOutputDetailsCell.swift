//  TransactiontOutputDetailsTableViewCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class TransactiontOutputDetailsCell: UITableViewCell {
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet weak var creditsStack: UIStackView!
    
    @IBOutlet weak var alcCreditStackHeight: NSLayoutConstraint!
    
    var expandOrCollapse: (() -> Void)?
   
    
    func setup(with credits:[Credit]){
        let _ = creditsStack.arrangedSubviews.map({self.creditsStack.removeArrangedSubview($0)})
        credits.forEach { (credit) in
            self.addSubrow(with: credit)
        }
        alcCreditStackHeight.constant = CGFloat(45)
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewContainer.isHidden = false
        expandOrCollapse?()
    }
    
    private func addSubrow(with credit: Credit){
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width:self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        let addressLabel = UILabel(frame: CGRect(x:5.0, y:23.0, width:self.frame.size.width, height: 22.0))
        let tmp = SingleInstance.shared.wallet
        let accName = tmp?.accountName(Int32(credit.Account))
        addressLabel.textColor = #colorLiteral(red: 0.2470588235, green: 0.4941176471, blue: 0.8901960784, alpha: 1)
        subrow.addSubview(amountLabel)
        subrow.addSubview(addressLabel)
        amountLabel.text = "\(credit.dcrAmount) DCR (\(accName ?? "external"))"
        amountLabel.font = amountLabel.font.withSize(15)
        addressLabel.text = credit.Address
        addressLabel.font = addressLabel.font.withSize(14)
        self.creditsStack.addArrangedSubview(subrow)
    }
}
