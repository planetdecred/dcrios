//
//  PasswordSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import PasswordStrength

class PasswordSetupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var lbMatchIndicator: UILabel!
    @IBOutlet weak var pbPasswordStrength: UIProgressView!
    @IBOutlet weak var lbPasswordStrengthLabel: UILabel!
    @IBOutlet weak var headerText: UILabel!
    
    let passwordStrengthMeasurer = MEPasswordStrength()
    
    var pageTitle: String?
    var onUserEnteredPassword: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfPassword.delegate = self
        tfConfirmPassword.delegate = self
        
        // add editing changed target to check if password matches
        tfPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfConfirmPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        headerText.text = self.pageTitle ?? "Setup Password"
    }
    
    @objc func textFieldDidChange(_: NSObject) {
        if self.tfPassword.text == self.tfConfirmPassword.text {
            self.lbMatchIndicator.textColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1)
            self.lbMatchIndicator.text = "PASSWORDS MATCH"
        } else {
            self.lbMatchIndicator.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.lbMatchIndicator.text = "PASSWORDS DO NOT MATCH"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.tag == 5) {
            // password field, caculate and display password strength
            pbPasswordStrength.progress = passwordStrengthMeasurer.strength(forPassword: textField.text) as! Float
            pbPasswordStrength.progressTintColor = passwordStrengthMeasurer.strengthColor(forPassword: textField.text)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let password = self.tfPassword.text ?? ""
        if password.length == 0 {
            self.showMessageDialog(title: "Error", message: "Empty password not allowed")
            return false
        }
        
        if self.tfPassword.text != self.tfConfirmPassword.text {
            self.showMessageDialog(title: "Error", message: "Password does not match")
            return false
        }
        
        self.onUserEnteredPassword?(self.tfPassword.text!)
        self.navigationController?.popToRootViewController(animated: true)
        return true
    }
    
    func showError(error:Error) {
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
