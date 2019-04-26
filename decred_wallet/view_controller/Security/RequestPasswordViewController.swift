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
//            if (senders == "launcher") {
//                password_Unlock()
//            } else if (senders == "settings") {
//                if (UserDefaults.standard.bool(forKey: "secure_wallet")){
//                    RemovestartupPassword()
//                }
//            } else if (senders == "settingsChangeSpending") {
//                let sendVC = storyboard!.instantiateViewController(withIdentifier: "SecurityViewController") as! SecurityViewController
//                sendVC.senders = "settingsChangeSpending"
//                sendVC.pass_pinToVerify = self.passwordText.text
//
//                self.navigationController?.pushViewController(sendVC, animated: true)
//            }else if (senders == "settingsChangeStartup") {
//                let sendVC = storyboard!.instantiateViewController(withIdentifier: "SecurityViewController") as! SecurityViewController
//                sendVC.senders = "settingsChangeStartup"
//                sendVC.pass_pinToVerify = self.passwordText.text
//
//                self.navigationController?.pushViewController(sendVC, animated: true)
//            }
//        }
    }
    
    func setHeader(){
//        if (senders == "launcher") {
//            headerText.text = "Enter StartUp Password"
//        } else if (senders == "settings") {
//            if (UserDefaults.standard.bool(forKey: "secure_wallet")) {
//                headerText.text = "Enter Current Password"
//            }
//        } else if (senders == "settingsChangeSpending") {
//            headerText.text = "Enter Spending Password"
//        }
//        else if (senders == "settingsChangeStartup") {
//            headerText.text = "Enter StartUp Password"
//        }
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
                    this.showError(error)
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
    
    func showError(_ error: Error){
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    
//
//    func RemovestartupPassword(){
//
//        self.progressHud?.show(animated: true)
//        self.progressHud?.label.text = "Removing Security"
//
//        let key = "public"
//        let finalkey = key as NSString
//        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
//        let pass = self.passwordText.text
//        let finalpass = pass! as NSString
//        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            do {
//                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeypassData, newPass: finalkeyData)
//                DispatchQueue.main.async {
//                    this.progressHud?.hide(animated: true)
//
//                    UserDefaults.standard.set(false, forKey: "secure_wallet")
//                    UserDefaults.standard.synchronize()
//                    self?.dismissView()
//                }
//                return
//            } catch let error {
//                DispatchQueue.main.async {
//                    this.progressHud?.hide(animated: true)
//                    this.showError(error: error)
//                }
//            }
//        }
//    }
//
//    func createMenu(){
//
//    }
//
}
