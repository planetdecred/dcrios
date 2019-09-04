//
//  PasswordSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class PasswordSetupViewController: SecurityBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var passwordInput: FloatingLabelTextInput!
    @IBOutlet weak var confirmPasswordInput: FloatingLabelTextInput!
    
    @IBOutlet weak var passwordStrengthIndicator: UIProgressView!
    
    @IBOutlet weak var passwordCountLabel: UILabel!
    @IBOutlet weak var confirmCountLabel: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmErrorLabel: UILabel!
    
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var onUserEnteredPassword: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapAround()
        
        self.setupInterface()
        
        // calculate password strength when password changes; and check if password matches
        self.passwordInput.addTarget(self, action: #selector(self.passwordTextFieldChange), for: .editingChanged)
        // add editing changed target to check if password matches
        self.confirmPasswordInput.addTarget(self, action: #selector(self.confirmPasswordTextFieldChange), for: .editingChanged)
        
        // display keyboard for input
        self.passwordInput.becomeFirstResponder()
        
        // set textfield delegates to move to next field or submit password on return key press
        self.passwordInput.delegate = self
        self.confirmPasswordInput.delegate = self
    }
    
    private func setupInterface() {
        self.passwordInput.layer.cornerRadius = 7
        self.passwordInput.isSecureTextEntry = true
        self.passwordInput.addViewPasswordButton()
        
        self.confirmPasswordInput.layer.cornerRadius = 7
        self.confirmPasswordInput.isSecureTextEntry = true
        self.confirmPasswordInput.addViewPasswordButton()
        
        self.createBtn.layer.cornerRadius = 7
    }
    
    @objc func passwordTextFieldChange() {
        let passwordStrength = PinPasswordStrength.percentageStrength(of: self.passwordInput.text ?? "")
        self.passwordStrengthIndicator.progress = passwordStrength.strength
        self.passwordStrengthIndicator.progressTintColor = passwordStrength.color
        
        if self.passwordInput.text == ""{
            self.passwordCountLabel.text = "\(0)"
        }else{
            self.passwordCountLabel.text = "\(self.passwordInput.text!.count)"
        }
        self.checkPasswordMatch()
    }
    
    @objc func confirmPasswordTextFieldChange() {
        self.checkPasswordMatch()
    }
    
    func checkPasswordMatch() {
        createBtn.setBackgroundColor(UIColor.appColors.lightGray, for: .normal)
        
        if self.confirmPasswordInput.text == "" {
            self.confirmErrorLabel.textColor = UIColor.appColors.decredOrange
            self.confirmErrorLabel.text = LocalizedStrings.passwordsDoNotMatch
            self.createBtn.isEnabled = false
            
        } else if self.passwordInput.text == self.confirmPasswordInput.text {
            self.confirmErrorLabel.textColor = UIColor.appColors.green
            self.confirmErrorLabel.text = LocalizedStrings.passwordMatch
            self.createBtn.isEnabled = true
            createBtn.setBackgroundColor(UIColor.appColors.decredBlue, for: .normal)
        } else {
            self.confirmErrorLabel.textColor = UIColor.appColors.decredOrange
            self.confirmErrorLabel.text = LocalizedStrings.passwordsDoNotMatch
            self.createBtn.isEnabled = false
        }
        
        self.confirmCountLabel.text = (self.confirmPasswordInput.text != "") ? "\(self.confirmPasswordInput.text!.count)" : "0"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordInput {
            self.confirmPasswordInput.becomeFirstResponder()
            return true
        }
        return self.validatePasswordsAndProceed()
    }
    
    @IBAction func cancelTapped(_sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func createTapped(_ sender: UIButton) {
        createBtn.isEnabled = false
        _ = self.validatePasswordsAndProceed()
    }
    
    func validatePasswordsAndProceed() -> Bool {
        let password = self.passwordInput.text ?? ""
        if password.length == 0 {
            self.showMessageDialog(title: LocalizedStrings.error, message: LocalizedStrings.emptyPasswordNotAllowed)
            createBtn.isEnabled = true
            return false
        }
        
        if self.passwordInput.text != self.confirmPasswordInput.text {
            self.showMessageDialog(title: LocalizedStrings.error, message: LocalizedStrings.passwordsDoNotMatch)
            createBtn.isEnabled = true
            return false
        }
        
        // only quit VC if not part of the SecurityVC tabs
        if self.tabBarController == nil {
            self.close()
        }
        self.onUserEnteredPassword?(self.passwordInput.text!)
        return true
    }
    
    private func close() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
