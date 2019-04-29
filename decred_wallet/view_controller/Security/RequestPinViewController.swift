//
//  PinSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD
import Dcrlibwallet

class RequestPinViewController: UIViewController {
    var prompt: String?
    var showCancelButton = false
    
    var openWalletOnEnterPin = false
    var onUserEnteredPin: ((_ pin: String) -> Void)?
    
    var requestPinConfirmation = false
    var pinToConfirm: String = ""
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var pinInputView: PinInputView!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    @IBOutlet weak var btnCommit: UIButton!
    
    var progressHud: JGProgressHUD?
    var pinStrength = PinWeakness()
    
    override func viewDidLoad() {
        self.headerText.text = self.prompt
        if self.showCancelButton {
            cancelBtn.isHidden = false
        }
        prgsPinStrength.layer.cornerRadius = 25
    }
    
    @IBAction func onDigitButtonTapped(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let digit = (sender as! UIView).tag
        let pin = self.pinInputView.append(digit: digit)
        self.pinUpdated(pin: pin)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @IBAction func onBackspaceTapped(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let pin = self.pinInputView.backspace()
        self.pinUpdated(pin: pin)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func pinUpdated(pin: String) {
        self.prgsPinStrength.progressTintColor = pinStrength.strengthColor(forPin: pin)
        self.prgsPinStrength.progress = pinStrength.strength(forPin: pin)
        self.btnCommit.isEnabled = pin.count > 0
    }
    
    @IBAction func onOkButtonTapped(_ send: Any) {
        if self.pinInputView.pin == "" {
            return
        }
        
        if self.requestPinConfirmation && pinToConfirm == "" {
            self.pinToConfirm = self.pinInputView.pin
            self.pinInputView.clear()
            headerText.text = "Re-enter PIN"
        }
        else if requestPinConfirmation && pinToConfirm != pinInputView.pin {
            self.pinToConfirm = ""
            self.pinInputView.clear()
            self.headerText.text = "PINs do not match. Try again"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.headerText.text = self.prompt
            }
        } else if self.onUserEnteredPin == nil && self.openWalletOnEnterPin {
            self.unlockWalletAndStartApp(password: self.pinInputView.pin)
        } else {
            self.onUserEnteredPin?(self.pinInputView.pin)
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func unlockWalletAndStartApp(password: String) {
        self.progressHud = showProgressHud(with: "Opening wallet")
        
        let walletPassphrase = (password as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.open(walletPassphrase)
                this.startApp()
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showOkAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    func startApp() {
        DispatchQueue.main.async {
            self.progressHud?.dismiss()
            createMainWindow()
        }
    }
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func dismissView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setHeader(){
        // Hide progress bar when entering pin
//        if(isChange){
//            headerText.text = "Enter Current PIN"
//        }else{
//            if(isSpendingPassword){
//                if(isSecure){
//                     headerText.text = "Enter Current PIN"
//                }else{
//                    headerText.text = "Enter Spending PIN"
//                }
//            }else{
//                if(isSecure){
//                    headerText.text = "Create Startup PIN"
//                }else{
//                    headerText.text = "Enter Startup PIN"
//                }
//            }
//        }
    }
    
//    func createWallet(){
//
//        progressHud = showProgressHud(with: "creating wallet...")
//
//        let seed = self.seedToVerify!
//        let pass = self.pin
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            do {
//                if SingleInstance.shared.wallet == nil {
//                    return
//                }
//
//                let wallet = SingleInstance.shared.wallet!
//
//                try wallet.createWallet(pass, seedMnemonic: seed)
//                try wallet.unlock(pass.data(using: .utf8))
//                DispatchQueue.main.async {
//                    self!.progressHud!.dismiss()
//                    // TODO: do not save password in defaults
//                    self!.pinInput = pass
//                    UserDefaults.standard.set("PIN", forKey: "spendingSecureType") // this stuff
//                    UserDefaults.standard.synchronize()
//                    createMainWindow()
//                    this.dismiss(animated: true, completion: nil)
//                }
//                return
//            } catch let error {
//                DispatchQueue.main.async {
//                    self!.progressHud!.dismiss()
//                    this.showError(error: error)
//                    print("wallet error")
//                    print(error)
//                }
//            }
//        }
//    }
//
//    func SetstartupPin_pas(){
//        progressHud = showProgressHud(with: "securing wallet...")
//
//        let insecurePublicPass = ("public" as NSString).data(using: String.Encoding.utf8.rawValue)!
//        let pass = (self.pin as NSString).data(using: String.Encoding.utf8.rawValue)
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            do {
//                try SingleInstance.shared.wallet?.changePublicPassphrase(insecurePublicPass, newPass: pass)
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    UserDefaults.standard.set(true, forKey: "secure_wallet")
//                    UserDefaults.standard.setValue("PIN", forKey: "securitytype")
//                    UserDefaults.standard.synchronize()
//                    self?.dismissView()
//                }
//                return
//            } catch let error {
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    this.showError(error: error)
//                }
//            }
//        }
//    }
    
//    func pass_PIn_Unlock(){
//
//        progressHud = showProgressHud(with: "Opening wallet")
//
//        let finalkeypassData = (self.pin as NSString).data(using: String.Encoding.utf8.rawValue)!
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            do {
//                try SingleInstance.shared.wallet?.open(finalkeypassData)
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    self!.createMenu()
//                }
//                return
//            } catch let error {
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    this.showError(error: error)
//                }
//            }
//        }
//    }
//
//    func ChangeSpendingPIN(){
//
//        progressHud = showProgressHud(with: "Changing spending PIN...")
//
//        let finalkeyData = (pass_pinToVerify! as NSString).data(using: String.Encoding.utf8.rawValue)!
//        let finalkeypassData = (self.pin as NSString).data(using: String.Encoding.utf8.rawValue)!
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            do {
//                try SingleInstance.shared.wallet?.changePrivatePassphrase(finalkeyData, newPass: finalkeypassData)
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    UserDefaults.standard.setValue("PIN", forKey: "spendingSecureType")
//                    UserDefaults.standard.synchronize()
//                    self?.dismissView()
//                }
//                return
//            } catch let error {
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    this.showError(error: error)
//                }
//            }
//        }
//    }
//
//    func ChangeStartupPin(){
//        progressHud = showProgressHud(with: "Changing startup PIN...")
//
//        let startupPIN = (pass_pinToVerify! as NSString).data(using: String.Encoding.utf8.rawValue)!
//        let pass = (self.pin as NSString).data(using: String.Encoding.utf8.rawValue)
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            do {
//                try SingleInstance.shared.wallet?.changePublicPassphrase(startupPIN, newPass: pass)
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    UserDefaults.standard.set(true, forKey: "secure_wallet")
//                    UserDefaults.standard.setValue("PIN", forKey: "securitytype")
//                    UserDefaults.standard.synchronize()
//                    self?.dismissView()
//                }
//                return
//            } catch let error {
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    this.showError(error: error)
//                }
//            }
//        }
//    }
//
//    func RemovestartupPin_pas(){
//        progressHud = showProgressHud(with: "Removing Security")
//        let key = "public"
//        let finalkey = key as NSString
//        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
//        let pass = self.pin
//        let finalpass = pass as NSString
//        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            do {
//                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeypassData, newPass: finalkeyData)
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    UserDefaults.standard.set(false, forKey: "secure_wallet")
//                    UserDefaults.standard.synchronize()
//                    self?.dismissView()
//                }
//                return
//            } catch let error {
//                DispatchQueue.main.async {
//                    this.progressHud?.dismiss()
//                    this.showError(error: error)
//                }
//            }
//        }
//    }
//
//    func createMenu(){
//        createMainWindow()
//    }
//
//    func showError(error:Error){
//        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
//            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
//        }
//        alert.addAction(okAction)
//        present(alert, animated: true, completion: {self.progressHud!.dismiss()})
//    }
}
