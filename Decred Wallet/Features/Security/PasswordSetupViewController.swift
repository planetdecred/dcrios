//
//  PasswordSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class PasswordSetupViewController: SecurityBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var lbMatchIndicator: UILabel!
    @IBOutlet weak var pbPasswordStrength: UIProgressView!
    
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var onUserEnteredPassword: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapAround()
        
        // calculate password strength when password changes; and check if password matches
        self.tfPassword.addTarget(self, action: #selector(self.passwordTextFieldChange), for: .editingChanged)
        // add editing changed target to check if password matches
        self.tfConfirmPassword.addTarget(self, action: #selector(self.confirmPasswordTextFieldChange), for: .editingChanged)
        
        // display keyboard for input
        self.tfPassword.becomeFirstResponder()
        
        // set textfield delegates to move to next field or submit password on return key press
        self.tfPassword.delegate = self
        self.tfConfirmPassword.delegate = self
        
        self.headerText.text = String(format: LocalizedStrings.createPassword, self.securityFor)
        self.lbMatchIndicator.text = " " // use empty space so label height isn't reduced
    }
    
    @objc func passwordTextFieldChange() {
        let passwordStrength = PinPasswordStrength.percentageStrength(of: self.tfPassword.text ?? "")
        pbPasswordStrength.progress = passwordStrength.strength
        pbPasswordStrength.progressTintColor = passwordStrength.color
        
        self.checkPasswordMatch()
    }
    
    @objc func confirmPasswordTextFieldChange() {
        self.checkPasswordMatch()
    }
    
    func checkPasswordMatch() {
        if self.tfConfirmPassword.text == "" {
            self.lbMatchIndicator.text = " " // use empty space so label height isn't reduced
        } else if self.tfPassword.text == self.tfConfirmPassword.text {
            self.lbMatchIndicator.textColor = UIColor.appColors.green
            self.lbMatchIndicator.text = LocalizedStrings.passwordMatch
        } else {
            self.lbMatchIndicator.textColor = UIColor.appColors.yellowWarning
            self.lbMatchIndicator.text = LocalizedStrings.passwordDoNotMatch
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfPassword {
            self.tfConfirmPassword.becomeFirstResponder()
            return true
        }
        
        return self.validatePasswordsAndProceed()
    }
    
    @IBAction func onOkTapped(_ sender: Any) {
        _ = self.validatePasswordsAndProceed()
    }
    
    func validatePasswordsAndProceed() -> Bool {
        let password = self.tfPassword.text ?? ""
        if password.length == 0 {
            self.showMessageDialog(title: LocalizedStrings.error, message: LocalizedStrings.emptyPasswordNotAllowed)
            return false
        }
        
        if self.tfPassword.text != self.tfConfirmPassword.text {
            self.showMessageDialog(title: LocalizedStrings.error, message: LocalizedStrings.passwordsDoNotMatch)
            return false
        }
        
        // only quit VC if not part of the SecurityVC tabs
        if self.tabBarController == nil {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        self.onUserEnteredPassword?(self.tfPassword.text!)
        return true
    }
}
