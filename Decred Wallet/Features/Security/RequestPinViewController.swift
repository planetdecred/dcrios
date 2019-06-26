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

class RequestPinViewController: SecurityBaseViewController {
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var showCancelButton = false
    
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
            self.headerText.text = String(format: LocalizedStrings.createPIN, self.securityFor)
        } else {
            self.headerText.text = String(format: LocalizedStrings.enterPIN, self.securityFor)
            self.pinStrengthLabel.isHidden = true
            self.prgsPinStrength.isHidden = true
        }
        
        if self.showCancelButton {
            cancelBtn.isHidden = false
        }
        prgsPinStrength.layer.cornerRadius = 25
        btnCommit.adjustsImageWhenHighlighted = false
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
            self.headerText.text = String(format: LocalizedStrings.confirmPIN, self.securityFor)
            self.prgsPinStrength.progress = 0
            
            // We are confirming pin, hide the pin strength meter.
            self.pinStrengthLabel.isHidden = true
            self.prgsPinStrength.isHidden = true
        }
        else if requestPinConfirmation && pinToConfirm != pinInputView.pin {
            self.pinToConfirm = ""
            self.headerText.text = LocalizedStrings.pinsDidNotMatch
            
            // Reset the input
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.headerText.text = String(format: LocalizedStrings.createPIN, self.securityFor)
                self.pinInputView.clear()
                self.prgsPinStrength.progress = 0
                
                // We're re-requesting input, show the strength meter
                self.pinStrengthLabel.isHidden = false
                self.prgsPinStrength.isHidden = false
            }
        } else {
            // only quit VC if not part of the SecurityVC tabs
            if self.tabBarController == nil {
                self.dismissView()
            }
            
            self.onUserEnteredPin?(self.pinInputView.pin)
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
