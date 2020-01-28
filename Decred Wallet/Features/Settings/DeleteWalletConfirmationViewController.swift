//
//  DeleteWalletConfirmationViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class DeleteWalletConfirmationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dialogBackground: UIView!
    @IBOutlet weak var enterPasswordHint: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteWalletHeader: UILabel!
    
    var onDeleteWalletConfirmed: ((String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.deleteWalletHeader.text = "\(LocalizedStrings.deleteWallet)?"
        
        if SpendingPinOrPassword.currentSecurityType() == .password {
            self.passwordTextField.delegate = self
            self.passwordTextField.addTarget(self, action: #selector(self.passwordTextChanged), for: .editingChanged)
        } else {
            self.enterPasswordHint.isHidden = true
            self.passwordTextField.isHidden = true
            self.deleteButton.isEnabled = true
        }
        
        let layer = view.layer
        layer.frame = self.dialogBackground.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width:0.0, height:40.0);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.deleteButton.isEnabled {
            self.deleteWalletConfirmed(self.deleteButton)
        }
        return self.deleteButton.isEnabled
    }
    
    @objc func passwordTextChanged() {
        guard let password = self.passwordTextField.text, password.count > 0 else {
            self.deleteButton.isEnabled = false
            return
        }
        self.deleteButton.isEnabled = true
    }

    @IBAction func deleteWalletConfirmed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if SpendingPinOrPassword.currentSecurityType() == .password {
            self.onDeleteWalletConfirmed?(self.passwordTextField.text!)
        } else {
            self.onDeleteWalletConfirmed?(nil)
        }
    }
    
    @IBAction func cancelDeleteWalletOperation(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
