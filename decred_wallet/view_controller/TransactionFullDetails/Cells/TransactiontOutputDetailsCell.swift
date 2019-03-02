//  TransactiontOutputDetailsTableViewCell.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class TransactiontOutputDetailsCell: UITableViewCell {
    
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet weak var creditsStack: UIStackView!
    @IBOutlet weak var alcCreditStackHeight: NSLayoutConstraint!
    
    var index = 0
    
    var expandOrCollapse: (() -> Void)?
    
    var presentingController: TransactionFullDetailsViewController!
    
    func setup(with credits:[Credit], decodedOutputs: [DecodedOutput], presentingController: TransactionFullDetailsViewController){
        alcCreditStackHeight.constant = 0
        self.presentingController = presentingController
        
        var walletOutputIndices = [Int]()
        
        let wallet = SingleInstance.shared.wallet
        
        for (_, credit) in credits.enumerated() {
            walletOutputIndices.append(Int(credit.Index))
            
            let amount = getAttributedString(str: "\(credit.dcrAmount.round(8))", siz: 13, TexthexColor: GlobalConstants.Colors.TextAmount)
            let title = " (\((wallet?.account(ofAddress: credit.Address))!))"
            let address = credit.Address
            
            addSubrow(with: amount, title: title, subTitle: address)
            
            index += 1
            alcCreditStackHeight.constant = alcCreditStackHeight.constant + 45
        }
        
        for(i, decodedOutput) in decodedOutputs.enumerated() {
            if walletOutputIndices.contains(i) {
                continue
            }
            
            var address = decodedOutput.Addresses.count > 0 ? decodedOutput.Addresses[0] : ""
            var amount = getAttributedString(str: "\(decodedOutput.dcrAmount.round(8))", siz: 13, TexthexColor: GlobalConstants.Colors.TextAmount)
            var title = " (external)"
            
            switch(decodedOutput.ScriptType){
            case "nulldata":
                amount = NSAttributedString(string: "[null data]")
                address = "[script]"
                title = ""
                break
            case "stakegen":
                address = "[stakegen]"
                break
            default:
                break
            }
            
            addSubrow(with: amount, title: title, subTitle: address)
            
            index += 1
            alcCreditStackHeight.constant = alcCreditStackHeight.constant + 45
        }
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewContainer.isHidden = false
    }
    
    private func addSubrow(with amount: NSAttributedString, title: String, subTitle: String){
    
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
        combine.append(amount)
        combine.append(NSMutableAttributedString(string: title))
        amountLabel.attributedText = combine
        subTitleLabel.setTitle(subTitle, for: .normal)
        
        creditsStack.insertArrangedSubview(subrow, at: index)
    }
    
    @objc func buttonClicked(sender : UIButton){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = sender.titleLabel?.text
            //Alert
            let alertController = UIAlertController(title: "", message: "Address copied!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.presentingController.present(alertController, animated: true, completion: nil)
        }
    }
}
