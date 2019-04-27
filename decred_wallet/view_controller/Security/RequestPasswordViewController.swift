//
//  RequestPasswordViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import MBProgressHUD

class RequestPasswordViewController: UIViewController {
    @IBOutlet weak var lblPrompt: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    var progressHud : MBProgressHUD?
    
    var prompt: String?
    var openWalletOnEnterPassword = false
    var onUserEnteredPinOrPassword: ((_ password: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblPrompt.text = self.prompt ?? "Enter Password"
        
        progressHud = MBProgressHUD(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        view.addSubview(progressHud!)
    }
    
    @IBAction func OKAction(_ sender: Any) {
        let password = self.tfPassword.text ?? ""
        if password.length == 0 {
            return
        }
        
        if onUserEnteredPinOrPassword == nil && openWalletOnEnterPassword {
            unlockWalletAndStartApp(password: password)
        } else {
            onUserEnteredPinOrPassword?(password)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func unlockWalletAndStartApp(password: String) {
        self.progressHud?.show(animated: true)
        self.progressHud?.label.text = "Opening wallet"

        let walletPassphrase = (password as NSString).data(using: String.Encoding.utf8.rawValue)!

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }

            do {
                try SingleInstance.shared.wallet?.open(walletPassphrase)
                this.startApp()
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.hide(animated: true)
                    this.showOkAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    func startApp() {
        DispatchQueue.main.async {
            self.progressHud?.hide(animated: true)
            createMainWindow()
        }
    }
}
