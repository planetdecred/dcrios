//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class ConfirmToSendFundViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dialogBackground: UIView!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmSendButton: UIButton!
    
    var sendAmount: String?
    var fee: String?
    var destinationAddress: String?
    var destinationAccount: String?
    var sendTxConfirmed: ((String?) -> Void)?
    
    struct Amount {
        var dcrValue: NSDecimalNumber
        var usdValue: NSDecimalNumber?
    }
    
    static func requestConfirmation(amountToSend: Amount, estimatedFee: Amount, destinationAddress: String, destinationAccount: String?, onConfirmed: ((String?) -> Void)?) {
        let confirmVC = Storyboards.Send.instantiateViewController(for: self)
        
        confirmVC.sendAmount = "\(amountToSend.dcrValue.round(8).formattedWithSeparator) DCR"
        if amountToSend.usdValue != nil {
            confirmVC.sendAmount! += " ($\(amountToSend.usdValue!.round(4).formattedWithSeparator))"
        }
        
        confirmVC.fee = "\(estimatedFee.dcrValue.round(8).formattedWithSeparator) DCR"
        if estimatedFee.usdValue != nil {
            confirmVC.fee! += " ($\(estimatedFee.usdValue!.round(4).formattedWithSeparator))"
        }
        
        confirmVC.destinationAddress = destinationAddress
        confirmVC.destinationAccount = destinationAccount
        confirmVC.sendTxConfirmed = onConfirmed
        
        confirmVC.modalTransitionStyle = .crossDissolve
        confirmVC.modalPresentationStyle = .overCurrentContext
        AppDelegate.shared.window?.rootViewController?.present(confirmVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendAmountLabel.text = "Sending \(self.sendAmount!)"
        self.feeLabel.text = "with a fee of \(self.fee!)"
        self.addressLabel.text = "to " + self.destinationAddress!
        
        if self.destinationAccount == nil {
            self.accountLabel.isHidden = true
        } else {
            self.accountLabel.text = "to account \'\(self.destinationAccount!)\'"
        }
        
        if SpendingPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            self.passwordTextField.delegate = self
            self.passwordTextField.addTarget(self, action: #selector(self.passwordTextChanged), for: .editingChanged)
        } else {
            self.passwordTextField.isHidden = true
            self.confirmSendButton.isEnabled = true
        }
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let layer = self.view.layer
        layer.frame = dialogBackground.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: 0, height: 40)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.confirmSendButton.isEnabled {
            self.confirmSend()
        }
        return self.confirmSendButton.isEnabled
    }
    
    @objc func passwordTextChanged() {
        guard let password = self.passwordTextField.text, password.count > 0 else {
            self.confirmSendButton.isEnabled = false
            return
        }
        self.confirmSendButton.isEnabled = true
    }

    @IBAction private func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func confirmAction(_ sender: UIButton) {
        self.confirmSend()
    }
    
    func confirmSend() {
        self.dismiss(animated: true, completion: nil)
        if SpendingPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            self.sendTxConfirmed?(self.passwordTextField.text!)
        } else {
            self.sendTxConfirmed?(nil)
        }
    }
}
