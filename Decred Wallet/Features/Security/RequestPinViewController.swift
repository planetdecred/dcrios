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
    
    var submitEnabled: Bool = false {
        didSet {
            if self.submitEnabled == true {
                self.btnCommit.isEnabled = true
                btnCommit.setBackgroundColor(UIColor.appColors.decredBlue, for: .normal)
            }else {
                self.btnCommit.isEnabled = false
                btnCommit.setBackgroundColor(UIColor.appColors.darkGray, for: .normal)
            }
        }
    }

    @IBOutlet weak var btnCommit: UIButton!
    
    @IBOutlet weak var pinInput: FloatingLabelTextInput!
    @IBOutlet weak var pinInputConfirm: FloatingLabelTextInput!
    
    @IBOutlet weak var pinErrorLabel: UILabel!
    @IBOutlet weak var confirmPinErrorLabel: UILabel!
    @IBOutlet weak var pinStrengthLabel: UILabel!
    @IBOutlet weak var pinCount: UILabel!
    @IBOutlet weak var prgsPinStrength: UIProgressView!
    
    override func viewDidLoad() {
        self.setupInterface()
        self.pinInput.becomeFirstResponder()
    }
    
    @objc func pinUpdated(){
        if pinInput.text != "" && pinInput.text != nil {
            if self.requestPinConfirmation{
                let pinStrength = PinPasswordStrength.percentageStrength(of: pinInput.text!)
                self.prgsPinStrength.progressTintColor = pinStrength.color
                self.prgsPinStrength.progress = pinStrength.strength
                prgsPinStrength.isHidden = false
                pinStrengthLabel.isHidden = false
            }
            self.submitEnabled = pinInput.text!.count > 3
        }
    }
    
    @IBAction func createTapped(_ sender: UIButton) {
        if self.requestPinConfirmation && (pinInputConfirm.text ?? "") == ""{
            
            // No confirmation was entered, ask for pin confirmation
            confirmPinErrorLabel.text = "Please confirm your PIN"
            self.pinInputConfirm.becomeFirstResponder()
            
            // We are confirming pin, hide the pin strength meter.
            self.pinStrengthLabel.isHidden = true
            self.prgsPinStrength.isHidden = true
            
        }else if self.requestPinConfirmation && pinInput.text != pinInputConfirm.text{
            confirmPinErrorLabel.isHidden = false
            confirmPinErrorLabel.text = "PINs did not match. Try again"
            pinInputConfirm.becomeFirstResponder()
        }else{
            if self.tabBarController == nil{
                self.dismissView()
            }
            
            self.onUserEnteredPin!(pinInput.text!)
        }
    }
    
    func setupInterface() {
        if self.requestPinConfirmation {
            pinInputConfirm.isHidden = false
            pinStrengthLabel.isHidden = false
            pinErrorLabel.isHidden = false
        
            pinInputConfirm.layer.cornerRadius = 7
            pinInputConfirm.isSecureTextEntry = true
            pinInputConfirm.addViewPasswordButton()
        }
        
        pinInput.layer.cornerRadius = 7
        pinInput.isSecureTextEntry = true
        pinInput.addViewPasswordButton()
        pinInput.addTarget(self, action: #selector(self.pinTextChanged), for: .editingChanged)
        
        prgsPinStrength.layer.cornerRadius = 25
        btnCommit.adjustsImageWhenHighlighted = false
        btnCommit.layer.cornerRadius = 7
    }
    
    @objc func pinTextChanged(){
        if pinInput.text == ""{
            pinCount.text = "\(0)"
        }else{
            pinCount.text = "\(pinInput.text!.count)"
        }
        self.pinUpdated()
    }
    
    func setupInterface(){
        if self.requestPinConfirmation{
            pinInputConfirm.isHidden = false
            pinStrengthLabel.isHidden = false
            pinErrorLabel.isHidden = false
        
            pinInputConfirm.layer.cornerRadius = 7
            pinInputConfirm.isSecureTextEntry = true
            pinInputConfirm.addViewPasswordButton()
        }
        
        pinInput.layer.cornerRadius = 7
        pinInput.isSecureTextEntry = true
        pinInput.addViewPasswordButton()
        pinInput.addTarget(self, action: #selector(self.pinTextChanged), for: .editingChanged)
        
        prgsPinStrength.layer.cornerRadius = 25
        btnCommit.adjustsImageWhenHighlighted = false
        btnCommit.layer.cornerRadius = 7
    }
    
    @objc func pinTextChanged(){
        if pinInput.text == ""{
            pinCount.text = "\(0)"
        }else{
            pinCount.text = "\(pinInput.text!.count)"
        }
        self.pinUpdated()
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