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
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var showCancelButton = false
    
    var openWalletOnEnterPin = false
    var onUserEnteredPin: ((_ pin: String) -> Void)?
    
    var requestPinConfirmation = false
    var pinToConfirm: String = ""
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var pinInputView: PinInputView!
    @IBOutlet weak var pinStrengthLabel: UILabel!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    @IBOutlet weak var btnCommit: UIButton!
    
    override func viewDidLoad() {
        if self.requestPinConfirmation {
            self.headerText.text = "Create \(self.securityFor) PIN"
        } else {
            self.headerText.text = "Enter \(self.securityFor) PIN"
            self.pinStrengthLabel.isHidden = true
            self.prgsPinStrength.isHidden = true
        }
        
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
        if self.requestPinConfirmation {
            let pinStrength = PinPasswordStrength.percentageStrength(of: pin)
            self.prgsPinStrength.progressTintColor = pinStrength.color
            self.prgsPinStrength.progress = pinStrength.strength
        }
        self.btnCommit.isEnabled = pin.count > 0
    }
    
    @IBAction func onOkButtonTapped(_ send: Any) {
        if self.pinInputView.pin == "" {
            return
        }
        
        if self.requestPinConfirmation && pinToConfirm == "" {
            self.pinToConfirm = self.pinInputView.pin
            self.pinInputView.clear()
            self.headerText.text = "Confirm \(self.securityFor) PIN"
            self.prgsPinStrength.progress = 0
        }
        else if requestPinConfirmation && pinToConfirm != pinInputView.pin {
            self.pinToConfirm = ""
            self.headerText.text = "PINs did not match. Try again"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.headerText.text = "Create \(self.securityFor) PIN"
                self.pinInputView.clear()
                self.prgsPinStrength.progress = 0
            }
        } else if self.onUserEnteredPin == nil && self.openWalletOnEnterPin {
            self.unlockWalletAndStartApp(password: self.pinInputView.pin)
        } else {
            // only quit VC if not part of the SecurityVC tabs
            if self.tabBarController == nil {
                self.dismissView()
            }
            
            self.onUserEnteredPin?(self.pinInputView.pin)
        }
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
    
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismissView()
    }

    func dismissView() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
