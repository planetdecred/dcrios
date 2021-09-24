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

class ConfirmToSendFundViewController: UIViewController, UITextFieldDelegate {
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
        
        let confirmSendFundsVC = ConfirmToSendFundViewController.instantiate(from: .Send)
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
        
        let mainTextColor = UIColor.appColors.text1
        let subTextColor = UIColor.appColors.text2

        let sourceAccountInfo = Utils.styleAttributedString(
            String(format: "Sending from <bold>%@</bold>", self.unsignedTxSummary.sourceAccountInfo), // localize!
            styles: [
                AttributedStringStyle(tag: "bold", fontFamily: "SourceSansPro-SemiBold", fontSize: 14, color: mainTextColor)
            ],
            defaultStyle: AttributedStringStyle(fontFamily: "SourceSansPro-Regular", fontSize: 14, color: subTextColor)
        )
        self.sendingFromLabel.attributedText = sourceAccountInfo
        
        if let destinationAccountInfo = self.unsignedTxSummary.destinationAccountInfo {
            self.destinationTypeLabel.text = LocalizedStrings.toSelf
            self.destinationInfoLabel.text = destinationAccountInfo
        } else {
            self.destinationTypeLabel.text = LocalizedStrings.toDestinationAddress
            self.destinationInfoLabel.text = self.unsignedTxSummary.destinationAddress
        }
        
        let amountText = Utils.amountShowedInEightDecimals(
            amount: self.unsignedTxSummary.dcrAmount.doubleValue, smallerTextSize: 15.0
        )
        
        let feeText = NSMutableAttributedString(
            string: "\(self.unsignedTxSummary.dcrFee.round(8).formattedWithSeparator) DCR"
        )
        
        let totalCostText = NSMutableAttributedString(
            string: self.unsignedTxSummary.dcrTotalCost.round(8).formattedWithSeparator
        )
        totalCostText.append(
            Utils.styleAttributedString(" DCR")
        )
        
        if let exchangeRate = self.exchangeRate {
            let sendingAmountUsd = self.unsignedTxSummary.dcrAmount.multiplying(by: exchangeRate)
            let sendingAmountUsdText = Utils.styleAttributedString(
                " ($\(sendingAmountUsd.round(2).formattedWithSeparator))",
                font: UIFont(name: "SourceSansPro-Regular", size: 25),
                color: subTextColor
            )
            amountText.append(sendingAmountUsdText)
            
            let feeUsd = self.unsignedTxSummary.dcrFee.multiplying(by: exchangeRate)
            feeText.append(
                 Utils.styleAttributedString(" ($\(feeUsd.round(4).formattedWithSeparator))", color: subTextColor)
            )
            
            let totalCostUsd = self.unsignedTxSummary.dcrTotalCost.multiplying(by: exchangeRate)
            totalCostText.append(
                Utils.styleAttributedString(" ($\(totalCostUsd.round(2).formattedWithSeparator))", color: subTextColor)
            )
        }
        
        self.sendingAmountLabel.attributedText = amountText
        self.txFeeLabel.attributedText = feeText
        self.totalCostLabel.attributedText = totalCostText
        
        self.balanceAfterSendLabel.text = "\(self.unsignedTxSummary.dcrBalanceAfterSending.round(8).formattedWithSeparator) DCR"
        
        self.sendButton.setTitle("\(LocalizedStrings.send.capitalizingFirstLetter()) \(self.unsignedTxSummary.dcrAmount.round(8).formattedWithSeparator) DCR", for: .normal)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let privatePassType = SpendingPinOrPassword.securityType(for: self.sourceWalletID)
        Security.spending(initialSecurityType: privatePassType)
            .with(prompt: LocalizedStrings.confirmToSend)
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestCurrentCode(sender: self) { privatePass, _, dialogDelegate in
                
                self.broadcastUnsignedTxInBackground(privatePass: privatePass) { error in
                    if error == nil {
                        dialogDelegate?.dismissDialog()
                        self.dismissView()
                        self.onSendCompleted?()
                    } else if error!.isInvalidPassphraseError {
                        let errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.sourceWalletID)
                        dialogDelegate?.displayPassphraseError(errorMessage: errorMessage)
                    } else {
                        print("send error:", error!.localizedDescription)
                        dialogDelegate?.dismissDialog()
                        Utils.showBanner(in: self.view.subviews.first!, type: .error, text: LocalizedStrings.failedToSendTryAgain)
                    }
                }
        }
    }
    
    func broadcastUnsignedTxInBackground(privatePass: String, next: @escaping (_ error: Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.unsignedTx.broadcast(privatePass.utf8Bits)
                DispatchQueue.main.async {
                    next(nil)
                }
                
            } catch let error {
                DispatchQueue.main.async {
                    next(error)
                }
            }
        }
    }
}
