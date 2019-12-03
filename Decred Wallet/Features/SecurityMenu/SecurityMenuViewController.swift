//
//  SecurityMenuViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import JGProgressHUD

class SecurityMenuViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var border3: UIView!
    @IBOutlet weak var border2: UIView!
    @IBOutlet weak var border1: UIView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var addressError: UILabel!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var messageError: UILabel!
    @IBOutlet weak var signature: UITextField!
    @IBOutlet weak var signatureError: UILabel!
    @IBOutlet weak var signMsgBtn: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var HeaderInfo: UILabel!
    @IBOutlet weak var syncInfoLabel: UILabel!
    private var barButton: UIBarButtonItem?
    var addressPass = false
    var messagePass = false
    var sigPass  = true
    var passphrase_word = ""
  
    
    var dcrlibwallet :DcrlibwalletLibWallet!
    
    var progressHud : JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dcrlibwallet = AppDelegate.walletLoader.wallet
        self.address.delegate = self
        self.signature.delegate = self
        self.message.delegate = self
        
        self.signature.placeholder = LocalizedStrings.signature
        self.address.placeholder = LocalizedStrings.address
        self.message.placeholder = LocalizedStrings.message
        
        if AppDelegate.walletLoader.isSynced {
            self.toggleView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LocalizedStrings.security

        if !AppDelegate.walletLoader.isSynced {
            syncInfoLabel.isHidden = false
            return
        }
        
        let clearFieldBtn = UIButton(type: .custom)
        clearFieldBtn.setImage(UIImage(named: "right-menu"), for: .normal)
        clearFieldBtn.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        clearFieldBtn.frame = CGRect(x: 0, y: 0, width: 10, height: 51)
        barButton = UIBarButtonItem(customView: clearFieldBtn)
        self.navigationItem.rightBarButtonItems = [barButton!]
        syncInfoLabel.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    @objc func showMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .cancel, handler: nil)
        
        let clearField = UIAlertAction(title: LocalizedStrings.clearFields, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.clearAllFields()
            
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(clearField )
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButton
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func clearAllFields(){
        self.address.text = nil
        self.message.text = nil
        self.signature.text = nil
        self.addressError.text = ""
        self.signatureError.text = ""
        self.signatureError.text = ""
        self.signMsgBtn.isEnabled = false
        self.addressPass = false
        self.sigPass = false
        self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
        self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
        self.copyBtn.isEnabled = false
        self.copyBtn.backgroundColor = UIColor(hex: "#F2F4F3")
        self.copyBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // figure out what the new string will be after the pending edit
        var updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if (textField == self.address) {
            if (updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == "") {
                self.addressError.text = ""
                self.signMsgBtn.isEnabled = false
                self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                self.checkCopyBtn(signatured: self.signature.text!)
                return true
            }
            
            if (dcrlibwallet.isAddressValid(updatedString)) {
                if(dcrlibwallet.haveAddress(updatedString)){
                    self.addressError.textColor = UIColor(hex: "#007AFF")
                    self.addressError.text = LocalizedStrings.validOwnAddr
                    addressPass = true
                } else {
                    self.addressError.textColor = UIColor.red
                    self.addressError.text = LocalizedStrings.validNotOwnAddr
                    addressPass = false
                }
            } else {
                self.addressError.textColor = UIColor.red
                self.addressError.text = LocalizedStrings.invalidAddr
                addressPass = false
            }
            
            let tmp = self.signature.text
            let msg = self.message.text
            let addr = updatedString
            if (tmp!.trimmingCharacters(in: .whitespaces).length > 0) {
                self.verifyMessage(signatures: tmp!, messages: msg!, address: addr!)
            }
        } else if (textField == self.message) {
            let addr = self.address.text
            if (updatedString != nil || updatedString?.trimmingCharacters(in: .whitespaces) != ""
                || updatedString?.trimmingCharacters(in: .whitespaces).length != 0){
                let tmp = self.signature.text!
                if(tmp.length > 0){
                    self.verifyMessage(signatures: tmp, messages: updatedString!, address: addr!)
                }
            } else {
                updatedString = ""
                let tmp = self.signature.text!
                if(tmp.length > 0){
                    self.verifyMessage(signatures: tmp, messages: updatedString!, address: addr!)
                }
            }
        } else if (textField == self.signature) {
            if (updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == "") {
                if(addressPass){
                    self.signatureError.text = ""
                    self.copyBtn.isEnabled = false
                    self.copyBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                    self.copyBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                    self.signMsgBtn.isEnabled = true
                    self.signMsgBtn.backgroundColor = UIColor(hex: "#007AFF")
                    self.signMsgBtn.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
                    self.sigPass = false
                    return true
                }
                else{
                    self.signatureError.text = ""
                    self.copyBtn.isEnabled = false
                    self.copyBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                    self.copyBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                    self.signMsgBtn.isEnabled = false
                    self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                    self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                    self.sigPass = false
                    return true
                }
                
            }
            
            
            let tmp = updatedString
            let addr = self.address.text
            self.verifyMessage(signatures: tmp!, messages: self.message.text!, address: addr!)
            self.checkCopyBtn(signatured: tmp!)
            return true
        }
        
        if (self.addressPass) {
            if (self.sigPass && (self.signature.text!.trimmingCharacters(in: .whitespaces).length) < 1) {
                self.signMsgBtn.isEnabled = true
                self.signMsgBtn.backgroundColor = UIColor(hex: "#007AFF")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
            } else {
                self.signMsgBtn.isEnabled = false
                self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
            }
        } else {
            self.signMsgBtn.isEnabled = false
            self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
            self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
        }
        
        self.checkCopyBtn(signatured: self.signature.text!)
        return true
    }
    
    func verifyMessage(signatures: String,messages :String, address:String) {
        let addressd = address.trimmingCharacters(in: .whitespaces)
        let message = messages
        let signatured = signatures
        let retV = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        
        if (signatured == "") {
            signatureError.text = ""
            self.sigPass = true
            return
        }
        
        if (dcrlibwallet.isAddressValid(addressd)) {
            do{
                try dcrlibwallet.verifyMessage(addressd, message: message, signatureBase64: signatured, ret0_: retV)
                if (retV[0]).boolValue {
                    self.signatureError.text = LocalizedStrings.verifiedSignature
                    self.signatureError.textColor = UIColor(hex: "#007AFF")
                    self.signMsgBtn.isEnabled = false
                    self.sigPass = true
                    self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                    self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                    return
                } else {
                    self.signatureError.text = LocalizedStrings.invalidSignature
                    self.signatureError.textColor = UIColor.red
                    self.signMsgBtn.isEnabled = false
                    self.sigPass = false
                    self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                    self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                    return
                }
            } catch {
                self.signatureError.text = ""
                self.signatureError.textColor = UIColor.red
                self.signMsgBtn.isEnabled = false
                self.sigPass = false
                self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                self.signatureError.text = LocalizedStrings.invalidSignature
            }
        } else {
            self.signatureError.text = LocalizedStrings.invalidSignature
            self.signatureError.textColor = UIColor.red
            self.signMsgBtn.isEnabled = false
            self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
            self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
        }
        return
    }
    
    private func askPassword() {
        if SpendingPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            let alert = UIAlertController(title: LocalizedStrings.security, message: LocalizedStrings.promptSpendingPassword, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = LocalizedStrings.password.lowercased()
                textField.isSecureTextEntry = true
            }
            
            let okAction = UIAlertAction(title: LocalizedStrings.proceed, style: .default) { _ in
                let tfPasswd = alert.textFields![0] as UITextField
                if (tfPasswd.text?.count)! > 0 {
                    self.SignMsg(pass: tfPasswd.text!)
                    alert.dismiss(animated: false, completion: nil)
                } else {
                    alert.dismiss(animated: false, completion: nil)
                    self.showAlert(message: LocalizedStrings.passwordEmpty, titles: LocalizedStrings.invalidInput)
                }
            }
            
            let CancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .default) { _ in
                alert.dismiss(animated: false, completion: nil)
            }
            alert.addAction(CancelAction)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let requestPinVC = RequestPinViewController.instantiate()
            requestPinVC.securityFor = LocalizedStrings.spending
            requestPinVC.showCancelButton = true
            requestPinVC.onUserEnteredPin = { pin in
                self.SignMsg(pass: pin)
            }
            self.present(requestPinVC, animated: true, completion: nil)
        }
    }
    
    private func showAlert(message: String? , titles: String?) {
        let alert = UIAlertController(title: titles, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LocalizedStrings.ok, style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func toggleView(){
        self.address.isHidden = !self.address.isHidden
        self.message.isHidden = !self.message.isHidden
        self.signature.isHidden = !self.signature.isHidden
        self.border1.isHidden = !self.border1.isHidden
        self.border2.isHidden = !self.border2.isHidden
        self.border3.isHidden = !self.border3.isHidden
        self.signMsgBtn.isHidden = !self.signMsgBtn.isHidden
        self.copyBtn.isHidden = !self.copyBtn.isHidden
        self.addressError.isHidden = !self.addressError.isHidden
        self.signatureError.isHidden = !self.signatureError.isHidden
        self.messageError.isHidden = !self.messageError.isHidden
        self.HeaderInfo.isHidden = !self.HeaderInfo.isHidden
    }
    
    func SignMsg(pass:String) {
        
        progressHud = Utils.showProgressHud(withText: LocalizedStrings.signingMessage)
        
        let address = self.address.text
        let message = self.message.text
        let finalPassphrase = pass as NSString
        let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                let signature = try self!.dcrlibwallet.signMessage(finalPassphraseData, address: address, message: message)
                DispatchQueue.main.async {
                    self!.progressHud?.dismiss()
                    this.signature.text = signature.base64EncodedString()
                    this.verifyMessage(signatures: self!.signature.text!, messages: message!, address: address!)
                    this.checkCopyBtn(signatured: self!.signature.text!)
                }
            } catch {
                DispatchQueue.main.async {
                    self!.progressHud?.dismiss()
                    let alertController = UIAlertController(title: "", message: LocalizedStrings.passwordInvalid, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
                    this.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkCopyBtn(signatured:String) {
        
        if(addressPass && sigPass && (signatured.trimmingCharacters(in: .whitespaces).length) > 0 ){
            self.copyBtn.isEnabled = true
            self.copyBtn.backgroundColor = UIColor(hex: "#007AFF")
            self.copyBtn.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
            return
        }
        
        self.copyBtn.isEnabled = false
        self.copyBtn.backgroundColor = UIColor(hex: "#F2F4F3")
        self.copyBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
        return
    }
    
    private func copyData(){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            let info = "\(LocalizedStrings.address): \(self.address.text ?? "") \n\(LocalizedStrings.message): \(self.message.text ?? "") \n\(LocalizedStrings.signature): \(self.signature.text ?? "")"
            UIPasteboard.general.string = info
            
            //Alert
            let alertController = UIAlertController(title: "", message: LocalizedStrings.copiedSuccessfully, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: LocalizedStrings.ok, style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func signMessage(_ sender: UIButton) {
        self.askPassword()
    }
    
    @IBAction func Copy(_ sender: Any) {
        self.copyData()
    }
}
