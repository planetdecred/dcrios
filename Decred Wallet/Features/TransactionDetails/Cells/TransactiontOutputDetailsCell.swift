//
//  TransactiontOutputDetailsTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactiontOutputDetailsCell: UITableViewCell {
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet weak var creditsStack: UIStackView!
    @IBOutlet weak var alcCreditStackHeight: NSLayoutConstraint!

    var expandOrCollapse: (() -> Void)?

    var presentingController: TransactionDetailsViewController!

    func setup(_ outputs:[TxOutput], presentingController: TransactionDetailsViewController) {
        self.presentingController = presentingController
        
        // this stack view comes with previous items when this function is called again
        creditsStack.subviews.forEach({ $0.removeFromSuperview() })

        for (_, output) in outputs.enumerated() {
            var amount = Utils.getAttributedString(
                str: "\(output.dcrAmount.round(8))",
                siz: 13,
                TexthexColor: UIColor.appColors.textAmount
            )
            var address = output.address
            
            var title = output.accountNumber >= 0 ? output.accountName: LocalizedStrings.external.lowercased()
            title = " (\(title))"
            
            switch (output.scriptType) {
            case "nulldata":
                amount = NSAttributedString(string: "[\(LocalizedStrings.nullData)]")
                address = "[\(LocalizedStrings.script)]"
                title = ""
                
            case "stakegen":
                address = "[\(LocalizedStrings.stakegen)]"
                
            default:
                break
            }

            addSubrow(with: amount, title: title, subTitle: address)
        }

        // each debit row has an height of 45
        alcCreditStackHeight.constant = CGFloat(45 * creditsStack.arrangedSubviews.count)
    }

    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewContainer.isHidden = false
    }

    private func addSubrow(with amount: NSAttributedString, title: String, subTitle: String) {
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width: self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        let subTitleLabel = UIButton(frame: CGRect(x: 5.0, y: 23, width: self.frame.size.width, height: 22.0))

        subTitleLabel.setTitleColor(#colorLiteral(red: 0.2470588235, green: 0.4941176471, blue: 0.8901960784, alpha: 1), for: .normal)
        subTitleLabel.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        subTitleLabel.set(fontSize: 15, name: "SourceSansPro-Regular")
        amountLabel.textColor = #colorLiteral(red: 0.03529411765, green: 0.07843137255, blue: 0.2509803922, alpha: 1)
        amountLabel.font = UIFont(name: "Inconsolata-Regular", size: 16)
        subTitleLabel.contentHorizontalAlignment = .left
        subrow.addSubview(amountLabel)
        subrow.addSubview(subTitleLabel)
        amountLabel.font = amountLabel.font.withSize(16)
        let combine = NSMutableAttributedString()
        combine.append(amount)
        combine.append(NSMutableAttributedString(string: title))
        amountLabel.attributedText = combine
        subTitleLabel.setTitle(subTitle, for: .normal)

        creditsStack.addArrangedSubview(subrow)
    }

    @objc func buttonClicked(sender : UIButton) {
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = sender.titleLabel?.text
            //Alert
            let alertController = UIAlertController(title: "", message: LocalizedStrings.addrCopied, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
            self.presentingController.present(alertController, animated: true, completion: nil)
        }
    }
}
