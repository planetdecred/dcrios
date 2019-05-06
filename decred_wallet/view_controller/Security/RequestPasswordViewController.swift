//
//  RequestPasswordViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import MBProgressHUD

class RequestPasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var lblPrompt: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    
    var prompt: String?
    var openWalletOnEnterPassword = false
    var onUserEnteredPinOrPassword: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblPrompt.text = self.prompt ?? "Enter Password"
        
        // set textfield delegates to move to next field or submit password on return key press
        self.tfPassword.delegate = self
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
        
        if self.onUserEnteredPinOrPassword == nil && self.openWalletOnEnterPassword {
            self.unlockWalletAndStartApp(password: password)
        } else if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        self.onUserEnteredPinOrPassword?(password)
        return true
    }
    
    func unlockWalletAndStartApp(password: String) {
        let progressHud = showProgressHud(with: "Opening wallet")

        let walletPassphrase = (password as NSString).data(using: String.Encoding.utf8.rawValue)!

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }

            do {
                try SingleInstance.shared.wallet?.open(walletPassphrase)
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    createMainWindow()
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    this.showOkAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
}
