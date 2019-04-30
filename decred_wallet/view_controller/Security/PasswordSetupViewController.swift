//
//  PasswordSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class PasswordSetupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var lbMatchIndicator: UILabel!
    @IBOutlet weak var pbPasswordStrength: UIProgressView!
    
    var pageTitle: String?
    var onUserEnteredPassword: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add editing changed target to check if password matches
        self.tfPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.tfConfirmPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // set textfield delegates to calculate password strength when password changes
        // and move to next field or submit password on return key press
        self.tfPassword.delegate = self
        self.tfConfirmPassword.delegate = self
        
        self.headerText.text = self.pageTitle ?? "Setup Password"
        self.lbMatchIndicator.text = ""
    }
    
    @objc func textFieldDidChange(_: NSObject) {
        if self.tfConfirmPassword.text == "" {
            self.lbMatchIndicator.text = ""
        } else if self.tfPassword.text == self.tfConfirmPassword.text {
            self.lbMatchIndicator.textColor = UIColor.AppColors.Green
            self.lbMatchIndicator.text = "PASSWORDS MATCH"
        } else {
            self.lbMatchIndicator.textColor = UIColor.AppColors.YellowWarning
            self.lbMatchIndicator.text = "PASSWORDS DO NOT MATCH"
        }
    }
    
    // caculate and display password strength on password field text change
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.tfPassword) {
            let passwordStrength = PinPasswordStrength.percentageStrength(of: textField.text ?? "")
            pbPasswordStrength.progress = passwordStrength.strength
            pbPasswordStrength.progressTintColor = passwordStrength.color
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfPassword {
            self.tfConfirmPassword.becomeFirstResponder()
            return true
        }
        
        return self.validatePaswordsAndProceed()
    }
    @IBAction func onOkTapped(_ sender: Any) {
    }
    
    func validatePaswordsAndProceed() -> Bool {
        let password = self.tfPassword.text ?? ""
        if password.length == 0 {
            self.showMessageDialog(title: "Error", message: "Empty password not allowed")
            return false
        }
        
        if self.tfPassword.text != self.tfConfirmPassword.text {
            self.showMessageDialog(title: "Error", message: "Passwords do not match")
            return false
        }
        
        self.onUserEnteredPassword?(self.tfPassword.text!)
        
        // only quit VC if not part of the SecurityVC tabs
        if !self.isTabBar {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        return true
    }
}
