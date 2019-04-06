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
        
        // calculate password strength when password changes; and check if password matches
        self.tfPassword.addTarget(self, action: #selector(self.passwordTextFieldChange), for: .editingChanged)
        // add editing changed target to check if password matches
        self.tfConfirmPassword.addTarget(self, action: #selector(self.confirmPasswordTextFieldChange), for: .editingChanged)
        
        // set textfield delegates to move to next field or submit password on return key press
        self.tfPassword.delegate = self
        self.tfConfirmPassword.delegate = self
        
        self.headerText.text = self.pageTitle ?? "Setup Password"
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
            self.lbMatchIndicator.textColor = UIColor.AppColors.Green
            self.lbMatchIndicator.text = "PASSWORDS MATCH"
        } else {
            self.lbMatchIndicator.textColor = UIColor.AppColors.YellowWarning
            self.lbMatchIndicator.text = "PASSWORDS DO NOT MATCH"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfPassword {
            self.tfConfirmPassword.becomeFirstResponder()
            return true
        }
        
        return self.validatePaswordsAndProceed()
    }
    
    @IBAction func onOkTapped(_ sender: Any) {
        _ = self.validatePaswordsAndProceed()
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
        if self.tabBarController == nil {
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        return true
    }
}
