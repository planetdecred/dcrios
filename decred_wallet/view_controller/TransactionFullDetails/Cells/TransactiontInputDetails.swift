//  TransactiontInputDetails.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class TransactiontInputDetails: UITableViewCell {
    
    @IBOutlet weak var viewCotainer: UIView!
    @IBOutlet weak var debitsStack: UIStackView!
    @IBOutlet weak var alcDebitStackHeight: NSLayoutConstraint!
    
    var expandOrCollapse: (() -> Void)?
    
    func setup(with debits:[Debit], decodedInputs: [DecodedInput]){
        alcDebitStackHeight.constant = 0
        
        var walletInputIndices = [Int]()
        
        var index = 0
        
        for (_, debit) in debits.enumerated() {
            
            walletInputIndices.append(Int(debit.Index))
        
            let decodedInput = decodedInputs[Int(debit.Index)]
        
            var hash = decodedInput.PreviousTransactionHash
            if hash == "0000000000000000000000000000000000000000000000000000000000000000" {
                hash = "Stakebase: 0000"
            }
            hash = "\(hash):\(decodedInput.PreviousTransactionIndex)"
            
            let amount = "\(debit.dcrAmount.round(8))"
            let title = " (\(debit.AccountName))"
            
            self.addSubrow(with: amount, title: title, subTitle: hash, index: index)
            index += 1
            alcDebitStackHeight.constant = alcDebitStackHeight.constant + 45
        }
        
        for (i, decodedInput) in decodedInputs.enumerated() {
            
            if walletInputIndices.contains(i) {
                continue
            }
            
            let amount = "\(decodedInput.dcrAmount.round(8))"
            let title = " (external)"
            
            var hash = decodedInput.PreviousTransactionHash
            if hash == "0000000000000000000000000000000000000000000000000000000000000000" {
                hash = "Stakebase: 0000"
            }
            hash = "\(hash):\(decodedInput.PreviousTransactionIndex)"
            
            self.addSubrow(with: amount, title: title, subTitle: hash, index: index)
            index += 1
            alcDebitStackHeight.constant = alcDebitStackHeight.constant + 45
        }
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewCotainer.isHidden = false
    }
    
    private func addSubrow(with amount: String, title: String, subTitle: String, index : Int) {
        
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width:self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        let subTitleLabel = UIButton(frame: CGRect(x: 5.0, y: 23, width: self.frame.size.width, height: 22.0))
        
        subTitleLabel.setTitleColor(#colorLiteral(red: 0.2470588235, green: 0.4941176471, blue: 0.8901960784, alpha: 1), for: .normal)
        subTitleLabel.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        subTitleLabel.set(fontSize: 15)
        amountLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        subTitleLabel.contentHorizontalAlignment = .left
        subrow.addSubview(amountLabel)
        subrow.addSubview(subTitleLabel)
        amountLabel.font = amountLabel.font.withSize(15)
        let combine = NSMutableAttributedString()
        combine.append(getAttributedString(str: amount, siz: 13, TexthexColor: GlobalConstants.Colors.TextAmount))
        combine.append(NSMutableAttributedString(string: title))
        amountLabel.attributedText = combine
        subTitleLabel.setTitle(subTitle, for: .normal)
        
        debitsStack.insertArrangedSubview(subrow, at: index)
        debitsStack.addArrangedSubview(subrow)
    }
    
    @objc func buttonClicked(sender : UIButton){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = sender.titleLabel?.text
            //Alert
            let alertController = UIAlertController(title: "", message: "address copied", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        }
    }
}
