//
//  RequestPasswordViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class RequestPasswordViewController: SecurityCodeRequestBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subtextLabel: UILabel!
    
    @IBOutlet weak var passwordInput: FloatingPlaceholderTextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordCountLabel: UILabel?
    @IBOutlet weak var passwordStrengthIndicator: ProgressView?

    @IBOutlet weak var confirmPasswordInput: FloatingPlaceholderTextField?
    @IBOutlet weak var confirmErrorLabel: UILabel?
    @IBOutlet weak var confirmCountLabel: UILabel?

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSubmit: Button!
    
    var dissmisSenderOnCancel = false
    
    var passwordTrials = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.passwordInput.becomeFirstResponder()
    }

    private func setupInterface() {
        if let prompt = self.request.prompt {
            self.headerLabel?.text = prompt
        } else {
            self.headerLabel?.removeFromSuperview()
        }
        
        if let subtext = self.request.subtext {
            self.subtextLabel?.text = subtext
        } else {
            self.subtextLabel?.removeFromSuperview()
        }
        
        self.passwordInput.placeholder = String(format: LocalizedStrings.passwordPlaceholder,
                                                self.request.for.localizedString)

        if self.request.isChangeAttempt {
            self.passwordInput.placeholder = String(format: LocalizedStrings.newPasswordPlaceholder,
                                                    self.request.for.localizedString.lowercased())

            self.btnSubmit.setTitle(self.request.submitBtnText ?? LocalizedStrings.change, for: .normal)
        } else {
            self.passwordInput.placeholder = String(format: LocalizedStrings.passwordPlaceholder,
                                                    self.request.for.localizedString)

            self.btnSubmit.setTitle(self.request.submitBtnText ?? LocalizedStrings.create, for: .normal)
        }
        
        self.passwordInput.isSecureTextEntry = true
        self.passwordInput.addTogglePasswordVisibilityButton()
        self.passwordInput.addTarget(self, action: #selector(self.passwordTextFieldChange), for: .editingChanged)
        self.passwordInput.delegate = self

        if self.request.requestConfirmation {
            if self.request.isChangeAttempt {
                self.confirmPasswordInput?.placeholder = String(format: LocalizedStrings.confirmNewPasswordPlaceholder,
                                                                self.request.for.localizedString.lowercased())
            } else {
                self.confirmPasswordInput?.placeholder = String(format: LocalizedStrings.confirmPasswordPlaceholder,
                                                                self.request.for.localizedString.lowercased())
            }
            
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

        if !self.request.showCancelButton {
            self.btnCancel?.removeFromSuperview()
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

        if self.request.requestConfirmation {
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
        self.btnSubmit.isEnabled = self.passwordInput.text != "" && confirmPassword != ""
        self.confirmCountLabel?.text = !confirmPassword.isEmpty ? "\(confirmPassword.count)" : "0"

        if self.passwordInput.text == confirmPassword || self.isInErrorState {
            self.confirmErrorLabel?.text = ""
            self.confirmCountLabel?.textColor = UIColor.appColors.darkBluishGray
            self.confirmPasswordInput?.hideError()
            self.confirmErrorLabel?.isHidden = true
            self.isInErrorState = false
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordInput && self.request.requestConfirmation {
            self.confirmPasswordInput?.becomeFirstResponder()
            return true
        }
        return self.validatePasswordsAndProceed()
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        if dissmisSenderOnCancel {
            self.dismissView()
            self.presentingViewController?.dismissView()
        } else {
            self.dismissView()
        }
    }

    @IBAction func createTapped(_ sender: UIButton) {
        _ = self.validatePasswordsAndProceed()
    }

    @IBAction func confirmPasswordEditingDidBegin(_ sender: Any) {
        self.confirmCountLabel?.isHidden = false
    }

    func validatePasswordsAndProceed() -> Bool {
        let password = self.passwordInput.text ?? ""

        if password.length == 0 {
            self.showMessageDialog(title: LocalizedStrings.error, message: LocalizedStrings.emptyPasswordNotAllowed)
            btnSubmit.isEnabled = false
            return false
        }

        if self.request.requestConfirmation {
            let confirmPassword = self.confirmPasswordInput?.text ?? ""
            if password != confirmPassword {
                self.confirmCountLabel?.textColor = UIColor.appColors.orange
                self.confirmErrorLabel?.text = LocalizedStrings.passwordsDoNotMatch
                self.confirmErrorLabel?.isHidden = false
                self.confirmPasswordInput?.showError()
                self.confirmPasswordInput?.becomeFirstResponder()
                self.btnSubmit.isEnabled = false
                self.isInErrorState = true
                return false
            }
            self.confirmPasswordInput?.resignFirstResponder()
        }

        self.passwordInput.resignFirstResponder()
        
        // Disable buttons and return password if `onCurrentAndNewCodesEntered` callback is NOT set.
        guard let currentAndNewCodesEnteredCallback = self.callbacks.onCurrentAndNewCodesEntered else {
            self.btnCancel?.isEnabled = false
            self.btnSubmit.isEnabled = false
            self.btnSubmit.startLoading()
            self.callbacks.onLoadingStatusChanged?(true)
            self.callbacks.onSecurityCodeEntered?(password, .password, self)
            return true
        }

        // `onCurrentAndNewCodesEntered` callback is set, request new code and notify callback.
        Security(for: self.request.for, initialSecurityType: .password)
            .requestNewCode(sender: self, isChangeAttempt: true) { newCode, newCodeType, newCodeRequestCompletion in
                
                currentAndNewCodesEnteredCallback(password, self, newCode, newCodeRequestCompletion, newCodeType)
        }
        return true
    }
    
    override func showPassphraseError(text: String) {
        passwordTrials = passwordTrials + 1
        
        _showError(text: text)
        self.passwordInput.isEnabled = false
        self.btnSubmit.isEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            var delay = 2.0
            if (self.passwordTrials % 2 == 0) {
                delay = 5.0
            }
            
            let delayTime = DispatchTime.now() + delay
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.passwordInput.text = ""
                self.hideError()
                self.passwordInput.isEnabled = true
                self.passwordInput.becomeFirstResponder()
            }

        }
    }
    
    override func showError(text: String) {
        super.showError(text: text)
        
        _showError(text: text)
    }
    
    func _showError(text: String) {
        self.passwordErrorLabel.text = text
        self.passwordErrorLabel.isHidden = false
        
        self.passwordInput?.showError()
        self.passwordInput.becomeFirstResponder()
        
        self.btnCancel?.isEnabled = true
        self.btnSubmit.isEnabled = true
        self.btnSubmit.stopLoading()
        self.callbacks.onLoadingStatusChanged?(false)
    }

    override func hideError() {
        super.hideError()
        self.passwordErrorLabel.isHidden = true
        self.passwordInput?.hideError()
    }
}
