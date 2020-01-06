//
//  RequestPasswordViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class RequestPasswordViewController: SecurityRequestBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var passwordInput: FloatingLabelTextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordCountLabel: UILabel?
    @IBOutlet weak var passwordStrengthIndicator: ProgressView?

    @IBOutlet weak var confirmPasswordInput: FloatingLabelTextField?
    @IBOutlet weak var confirmErrorLabel: UILabel?
    @IBOutlet weak var confirmCountLabel: UILabel?

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSubmit: Button!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTapAround()
        self.setupInterface()
    }

    private func setupInterface() {
        self.passwordInput.placeholder = String(format: LocalizedStrings.passwordPlaceholder, self.securityFor)
        self.passwordInput.isSecureTextEntry = true
        self.passwordInput.addTogglePasswordVisibilityButton()
        self.passwordInput.addTarget(self, action: #selector(self.passwordTextFieldChange), for: .editingChanged)
        self.passwordInput.becomeFirstResponder()
        self.passwordInput.delegate = self

        if self.requestConfirmation {
            self.confirmPasswordInput?.placeholder = String(format: LocalizedStrings.confirmPasswordPlaceholder, self.securityFor.lowercased())
            self.confirmPasswordInput?.isSecureTextEntry = true
            self.confirmPasswordInput?.addTogglePasswordVisibilityButton()
            self.confirmPasswordInput?.delegate = self
            self.confirmPasswordInput?.addTarget(self, action: #selector(self.confirmPasswordTextFieldChange), for: .editingChanged)
        } else {
            self.passwordStrengthIndicator?.removeFromSuperview()
            self.confirmPasswordInput?.removeFromSuperview()
            self.confirmCountLabel?.removeFromSuperview()
            self.confirmErrorLabel?.removeFromSuperview()
            self.passwordCountLabel?.removeFromSuperview()
        }

        if let prompt = self.prompt {
            self.headerLabel?.text = prompt
        } else {
            self.headerLabel?.removeFromSuperview()
        }

        if !self.showCancelButton {
            self.btnCancel?.removeFromSuperview()
        }

        if let submitBtnText = self.submitBtnText {
            self.btnSubmit.setTitle(submitBtnText, for: .normal)
        }
    }

    @objc func passwordTextFieldChange() {
        let password = self.passwordInput.text ?? ""
        let passwordStrength = PinPasswordStrength.percentageStrength(of: password)
        self.passwordStrengthIndicator?.progress = passwordStrength.strength
        self.passwordStrengthIndicator?.progressTintColor = passwordStrength.color
        self.passwordCountLabel?.text = (password == "") ? "\(0)" : "\(password.count)"

        if self.isInErrorState {
            self.hideError()
        }

        if self.requestConfirmation {
            self.checkPasswordMatch()
        } else {
            self.btnSubmit.isEnabled = password != ""
        }
    }

    @objc func confirmPasswordTextFieldChange() {
        self.checkPasswordMatch()
    }

    func checkPasswordMatch() {
        let confirmPassword = self.confirmPasswordInput?.text ?? ""
        if self.passwordInput.text != "" && confirmPassword != "" {
            if self.passwordInput.text != confirmPassword {
                self.confirmCountLabel?.textColor = UIColor.appColors.orange
                self.confirmErrorLabel?.text = LocalizedStrings.passwordsDoNotMatch
                self.confirmErrorLabel?.isHidden = false
                self.confirmPasswordInput?.showError()
                self.btnSubmit.isEnabled = false
            } else {
                self.confirmErrorLabel?.text = ""
                self.confirmCountLabel?.textColor = UIColor.appColors.darkBluishGray
                self.confirmPasswordInput?.hideError()
                self.confirmErrorLabel?.isHidden = true
                self.btnSubmit.isEnabled = true
            }
        }
        self.confirmCountLabel?.text = (confirmPassword != "") ? "\(confirmPassword.count)" : "0"
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordInput {
            self.confirmPasswordInput?.becomeFirstResponder()
            return true
        }
        return self.validatePasswordsAndProceed()
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismissView()
    }

    @IBAction func createTapped(_ sender: UIButton) {
        btnSubmit.isEnabled = false
        _ = self.validatePasswordsAndProceed()
    }

    func validatePasswordsAndProceed() -> Bool {
        let password = self.passwordInput.text ?? ""

        if password.length == 0 {
            self.showMessageDialog(title: LocalizedStrings.error, message: LocalizedStrings.emptyPasswordNotAllowed)
            btnSubmit.isEnabled = false
            return false
        }

        if self.requestConfirmation {
            let confirmPassword = self.confirmPasswordInput?.text ?? ""
            if password != confirmPassword {
                self.showMessageDialog(title: LocalizedStrings.error, message: LocalizedStrings.passwordsDoNotMatch)
                btnSubmit.isEnabled = false
                return false
            }
        }

        self.btnSubmit.isEnabled = false
        self.btnCancel?.isEnabled = false
        self.btnSubmit.startLoading()
        self.onUserEnteredSecurityCode?(password, self)
        return true
    }

    override func showError(text: String) {
        super.showError(text: text)
        self.btnSubmit.stopLoading()
        self.passwordInput.becomeFirstResponder()
        self.btnCancel?.isEnabled = true
        self.passwordErrorLabel.isHidden = false
        self.passwordErrorLabel.text = text
        self.passwordInput?.showError()
    }

    override func hideError() {
        super.hideError()
        self.passwordErrorLabel.isHidden = true
        self.passwordInput?.hideError()
    }
}
