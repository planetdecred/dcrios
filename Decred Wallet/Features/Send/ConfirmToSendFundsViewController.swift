//
//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

struct UnsignedTxSummary {
    var sourceAccountInfo: String
    var destinationAccountInfo: String?
    var destinationAddress: String
    var dcrAmount: NSDecimalNumber
    var dcrFee: NSDecimalNumber
    var dcrTotalCost: NSDecimalNumber
    var dcrBalanceAfterSending: NSDecimalNumber
}

class ConfirmToSendFundsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var sendingFromLabel: UILabel!
    @IBOutlet weak var sendingAmountLabel: UILabel!
    @IBOutlet weak var destinationTypeLabel: UILabel!
    @IBOutlet weak var destinationInfoLabel: UILabel!
    @IBOutlet weak var txFeeLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var balanceAfterSendLabel: UILabel!
    @IBOutlet weak var sendButton: Button!
    
    var sourceWalletID: Int!
    var unsignedTxSummary: UnsignedTxSummary!
    var unsignedTx: DcrlibwalletTxAuthor!
    var exchangeRate: NSDecimalNumber?
    var onSendCompleted: (() -> Void)?
    
    static func display(sender vc: UIViewController,
                        sourceWalletID: Int,
                        unsignedTxSummary: UnsignedTxSummary,
                        unsignedTx: DcrlibwalletTxAuthor,
                        exchangeRate: NSDecimalNumber?,
                        onSendCompleted: (() -> Void)?) {
        
        let confirmSendFundsVC = ConfirmToSendFundsViewController.instantiate(from: .Send)
        confirmSendFundsVC.sourceWalletID = sourceWalletID
        confirmSendFundsVC.unsignedTxSummary = unsignedTxSummary
        confirmSendFundsVC.unsignedTx = unsignedTx
        confirmSendFundsVC.exchangeRate = exchangeRate
        confirmSendFundsVC.onSendCompleted = onSendCompleted
        
        confirmSendFundsVC.modalTransitionStyle = .crossDissolve
        confirmSendFundsVC.modalPresentationStyle = .overCurrentContext
        
        vc.present(confirmSendFundsVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainTextColor = UIColor.appColors.darkBlue
        let subTextColor = UIColor.appColors.darkBluishGray

        let sourceAccountInfo = Utils.styleAttributedString(
            String(format: "Sending from <bold>%@</bold>", self.unsignedTxSummary.sourceAccountInfo), // localize!
            styles: [
                AttributedStringStyle(tag: "bold", fontFamily: "SourceSansPro-SemiBold", fontSize: 14, color: mainTextColor)
            ],
            defaultStyle: AttributedStringStyle(fontFamily: "SourceSansPro-Regular", fontSize: 14, color: subTextColor)
        )
        self.sendingFromLabel.attributedText = sourceAccountInfo
        
        if let destinationAccountInfo = self.unsignedTxSummary.destinationAccountInfo {
            self.destinationTypeLabel.text = "To self"
            self.destinationInfoLabel.text = destinationAccountInfo
        } else {
            self.destinationTypeLabel.text = "To destination address"
            self.destinationInfoLabel.text = self.unsignedTxSummary.destinationAddress
        }
        
        let amountText = Utils.amountAsAttributedString(
            amount: self.unsignedTxSummary.dcrAmount.doubleValue, smallerTextSize: 15.0
        )
        let feeText = NSMutableAttributedString(
            string: self.unsignedTxSummary.dcrFee.round(8).formattedWithSeparator
        )
        let totalCostText = NSMutableAttributedString(
            string: self.unsignedTxSummary.dcrTotalCost.round(8).formattedWithSeparator
        )
        
        if let exchangeRate = self.exchangeRate {
            let sendingAmountUsd = self.unsignedTxSummary.dcrAmount.multiplying(by: exchangeRate)
            let sendingAmountUsdText = Utils.styleAttributedString(
                " (\(sendingAmountUsd.round(4).formattedWithSeparator))",
                font: UIFont(name: "SourceSansPro-Regular", size: 25),
                color: subTextColor
            )
            amountText.append(sendingAmountUsdText)
            
            let feeUsd = self.unsignedTxSummary.dcrFee.multiplying(by: exchangeRate)
            feeText.append(
                Utils.styleAttributedString(" (\(feeUsd.round(8).formattedWithSeparator))", color: subTextColor)
            )
            
            let totalCostUsd = self.unsignedTxSummary.dcrTotalCost.multiplying(by: exchangeRate)
            totalCostText.append(
                Utils.styleAttributedString(" (\(totalCostUsd.round(8).formattedWithSeparator))", color: subTextColor)
            )
        }
        
        self.sendingAmountLabel.attributedText = amountText
        self.txFeeLabel.attributedText = feeText
        self.totalCostLabel.attributedText = totalCostText
        
        self.balanceAfterSendLabel.text = "\(self.unsignedTxSummary.dcrBalanceAfterSending.round(8).formattedWithSeparator) DCR"
        
        self.sendButton.setTitle("Send \(self.unsignedTxSummary.dcrAmount.round(8).formattedWithSeparator) DCR", for: .normal)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let privatePassType = SpendingPinOrPassword.securityType(for: self.sourceWalletID)
        Security.spending(initialSecurityType: privatePassType)
            .with(prompt: "Confirm to send") // todo localize
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestCurrentCode(sender: self) { privatePass, _, dialogDelegate in
                
                do {
                    try self.unsignedTx.broadcast(privatePass.utf8Bits)
                    dialogDelegate?.dismissDialog()
                    self.dismissView()
                    self.onSendCompleted?()
                } catch let error {
                    if error.isInvalidPassphraseError {
                        let errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.sourceWalletID)
                        dialogDelegate?.displayError(errorMessage: errorMessage)
                    } else {
                        print("send error:", error.localizedDescription)
                        dialogDelegate?.dismissDialog()
                        Utils.showBanner(in: self.view.subviews.first!, type: .error, text: "Failed to send. Please try again.")
                    }
                }
        }
    }
}
