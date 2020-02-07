//
//  TransactionOutputDetailsTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class TransactionOutputDetailsCell: UITableViewCell {
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var creditsStack: UIStackView!
    @IBOutlet weak var alcCreditStackHeight: NSLayoutConstraint!

    var expandOrCollapse: (() -> Void)?
    var onTxDetailValueCopied: ((_ bannerMsg: String) -> ())?
    var isCollapsed: Bool = true

    func setup(_ outputs: [TxOutput], isCollapsed: Bool) {
        self.isCollapsed = isCollapsed
        self.headerButton.setTitle(String(format: LocalizedStrings.outputsCreated, outputs.count), for: .normal)

        // this stack view comes with previous items when this function is called again
        creditsStack.subviews.forEach({ $0.removeFromSuperview() })
        let arrowImage = UIImage(named: "ic_collapse")

        if !self.isCollapsed {
            self.arrowImageView.image = arrowImage
            for (_, output) in outputs.enumerated() {
                var amount = Utils.getAttributedString(
                    str: "\(output.dcrAmount.round(8))",
                    siz: 13,
                    TexthexColor: UIColor.appColors.darkBlue
                )
                var address = output.address

                var title = output.accountNumber >= 0 ? output.accountName: LocalizedStrings.external.lowercased()
                title = " (\(title))"

                switch output.scriptType {
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
        } else {
         self.arrowImageView.image = UIImage(cgImage: (arrowImage?.cgImage!)!, scale: CGFloat(1.0), orientation: .downMirrored)
        }
        alcCreditStackHeight.constant = CGFloat(78 * creditsStack.arrangedSubviews.count)
        self.layoutIfNeeded()
    }

    @IBAction func expandOrCollapseAction(_ sender: UIButton) {
        self.expandOrCollapse?()
    }

    private func addSubrow(with amount: NSAttributedString, title: String, subTitle: String) {
        let subrow = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.creditsStack.frame.size.width, height: 78.0))
        let backgroundView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.creditsStack.frame.size.width, height: 70.0))
        let amountLabel = UILabel(frame: CGRect(x: 16.0, y: 16.0, width: self.creditsStack.frame.size.width - 32, height: 22.0))
        let subTitleLabel = UIButton(frame: CGRect(x: 16.0, y: 36, width: self.creditsStack.frame.size.width - 32, height: 22.0))

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
        combine.append(amount)
        combine.append(NSMutableAttributedString(string: title))
        amountLabel.attributedText = combine
        subTitleLabel.setTitle(subTitle, for: .normal)

        self.creditsStack.addArrangedSubview(subrow)
    }

    @objc func buttonClicked(sender: UIButton) {
        DispatchQueue.main.async {
            UIPasteboard.general.string = sender.titleLabel?.text
            self.onTxDetailValueCopied?(LocalizedStrings.addrCopied)
        }
    }
}
