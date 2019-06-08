//
//  RequestPasswordViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class RequestPasswordViewController: SecurityBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var lblPrompt: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    
    var prompt: String?
    var onUserEnteredPassword: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblPrompt.text = self.prompt ?? "Enter Password"
        
        // set textfield delegates to move to next field or submit password on return key press
        self.tfPassword.delegate = self
        self.tfPassword.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.validatePasswordAndProceed()
    }
    
    @IBAction func OKAction(_ sender: Any) {
        _ = self.validatePasswordAndProceed()
    }
    
    func validatePasswordAndProceed() -> Bool {
        let password = self.tfPassword.text ?? ""
        if password.length == 0 {
            return false
        }
        
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        self.onUserEnteredPassword?(password)
        return true
    }
}
