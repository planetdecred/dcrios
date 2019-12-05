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

    @IBOutlet weak var pinInput: FloatingLabelTextInput!
    @IBOutlet weak var pinInputConfirm: FloatingLabelTextInput!
    
    @IBOutlet weak var pinErrorLabel: UILabel!
    @IBOutlet weak var confirmPinErrorLabel: UILabel!
    @IBOutlet weak var pinCount: UILabel!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pinInput.becomeFirstResponder()
    }
    
    func setupInterface() {
        if self.requestPinConfirmation {
            pinInputConfirm.isSecureTextEntry = true
            pinInputConfirm.addViewPasswordButton()
            
            pinInputConfirm.isHidden = false
            pinErrorLabel.isHidden = false
        }
        
        pinInput.isSecureTextEntry = true
        pinInput.addViewPasswordButton()
        
        pinInput.addTarget(self, action: #selector(self.pinTextChanged), for: .editingChanged)
        
        prgsPinStrength.layer.cornerRadius = 25
    }
    
    @objc func pinTextChanged() {
        guard let pinText = pinInput.text else { return }
        
        pinCount.text = "\(pinText.count)"
        
        let isPinOk = pinText.count > 0

        if self.requestPinConfirmation {
            let pinStrength = PinPasswordStrength.percentageStrength(of: pinInput.text!)
            self.prgsPinStrength.progressTintColor = pinStrength.color
            self.prgsPinStrength.progress = pinStrength.strength
            prgsPinStrength.isHidden = false
        }
        
        self.btnSubmit.isEnabled = isPinOk
    }
    
    @IBAction func createTapped(_ sender: UIButton) {
        if self.requestPinConfirmation && (pinInputConfirm.text ?? "") == ""{
            
            // No confirmation was entered, ask for pin confirmation
            confirmPinErrorLabel.text = "Please confirm your PIN"
            self.pinInputConfirm.becomeFirstResponder()
            
            // We are confirming pin, hide the pin strength meter.
            self.prgsPinStrength.isHidden = true
            
        } else if self.requestPinConfirmation && pinInput.text != pinInputConfirm.text {
            confirmPinErrorLabel.isHidden = false
            confirmPinErrorLabel.text = "PINs did not match. Try again"
            pinInputConfirm.becomeFirstResponder()
        } else {
            if self.tabBarController == nil{
                self.dismissView()
            }
            
            self.onUserEnteredPin!(pinInput.text!)
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
