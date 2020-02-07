//  TransactionInputDetailsCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class TransactionInputDetailsCell: UITableViewCell {
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var debitsStack: UIStackView!
    @IBOutlet weak var alcDebitStackHeight: NSLayoutConstraint!

    var expandOrCollapse: (() -> Void)?
    var onTxDetailValueCopied: ((_ bannerMsg: String) -> ())?
    var isCollapsed: Bool = true

    func setup(_ inputs: [TxInput], isCollapsed: Bool) {
        self.isCollapsed = isCollapsed
        self.headerButton.setTitle(String(format: LocalizedStrings.inputsConsumed, inputs.count), for: .normal)
        // this stack view comes with previous items when this function is called again
        self.debitsStack.subviews.forEach({ $0.removeFromSuperview() })
        let arrowImage = UIImage(named: "ic_collapse")

        if !self.isCollapsed {
            self.arrowImageView.image = arrowImage
            for (_, input) in inputs.enumerated() {
                var hash = input.previousTransactionHash
                if hash == "0000000000000000000000000000000000000000000000000000000000000000" {
                    hash = "Stakebase: 0000"
                }
                hash = "\(hash):\(input.previousTransactionIndex)"
                
                let amount = "\(input.dcrAmount.round(8))"
                let title = " (\(input.accountName))"
                
                self.addSubrow(with: amount, title: title, subTitle: hash)
            }
        } else {
            self.arrowImageView.image = UIImage(cgImage: (arrowImage?.cgImage!)!, scale: CGFloat(1.0), orientation: .downMirrored)
        }

        self.alcDebitStackHeight.constant = CGFloat(78 * debitsStack.arrangedSubviews.count)
        self.layoutIfNeeded()
    }

    @IBAction func expandOrCollapseAction(_ sender: UIButton) {
        self.expandOrCollapse?()
    }

    private func addSubrow(with amount: String, title: String, subTitle: String) {
        let subrow = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.debitsStack.frame.size.width, height: 78.0))
        let backgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.debitsStack.frame.size.width, height: 70.0))
        let amountLabel = UILabel(frame: CGRect(x: 16.0, y: 16.0, width: self.debitsStack.frame.size.width - 32, height: 22.0))
        let subTitleLabel = UIButton(frame: CGRect(x: 16.0, y: 36, width: self.debitsStack.frame.size.width - 32, height: 22.0))

        backgroundView.backgroundColor = UIColor.appColors.offWhite
        backgroundView.layer.cornerRadius = 8.0
        backgroundView.layer.masksToBounds = true
        subrow.addSubview(backgroundView)

        subTitleLabel.setTitleColor(UIColor.appColors.lightBlue, for: .normal)
        subTitleLabel.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        subTitleLabel.set(fontSize: 14, name: "SourceSansPro-Regular")
        amountLabel.textColor = UIColor.appColors.darkBlue
        amountLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        subTitleLabel.contentHorizontalAlignment = .left
        backgroundView.addSubview(amountLabel)
        backgroundView.addSubview(subTitleLabel)
        let combine = NSMutableAttributedString()
        combine.append(Utils.getAttributedString(str: amount, siz: 16, TexthexColor: UIColor.appColors.darkBlue))
        combine.append(NSMutableAttributedString(string: title))
        amountLabel.attributedText = combine
        subTitleLabel.setTitle(subTitle, for: .normal)

        self.debitsStack.addArrangedSubview(subrow)
    }

    @objc func buttonClicked(sender: UIButton) {
        DispatchQueue.main.async {
            UIPasteboard.general.string = sender.titleLabel?.text
            self.onTxDetailValueCopied?(LocalizedStrings.previousOutpointCopied)
        }
    }
}
