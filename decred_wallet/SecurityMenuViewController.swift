//
//  SecurityMenuViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 11/12/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit
import Mobilewallet

class SecurityMenuViewController: UIViewController,UITextFieldDelegate {
    

    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var addressError: UILabel!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var messageError: UILabel!
    @IBOutlet weak var signature: UITextField!
    @IBOutlet weak var signatureError: UILabel!
    @IBOutlet weak var signMsgBtn: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var HeaderInfo: UILabel!
    var addressPass = false
    var messagePass = false
    var sigPass  = true
    var passphrase_word = ""
    var mobilewallet :MobilewalletLibWallet!
    override func viewDidLoad() {
        super.viewDidLoad()
        mobilewallet = SingleInstance.shared.wallet
        self.address.delegate = self
        self.signature.delegate = self
        self.message.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Security"
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // figure out what the new string will be after the pending edit
        var updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if textField == self.address{
            if updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == ""{
                self.addressError.text = ""
                print("address nothing")
                self.signMsgBtn.isEnabled = false
                self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                self.checkCopyBtn(signatured: self.signature.text!)
                return true
            }
            
            if(mobilewallet.isAddressValid(updatedString)){
                if(mobilewallet.haveAddress(updatedString)){
                    self.addressError.textColor = UIColor(hex: "#007AFF")
                    self.addressError.text = "Address is valid and you own it."
                    addressPass = true
                }
                else{
                    self.addressError.textColor = UIColor.red
                    self.addressError.text = "Address is valid and you do NOT own it."
                    addressPass = false
                }
            }
            else{
                self.addressError.textColor = UIColor.red
                self.addressError.text = "Not a valid address."
                addressPass = false
            }
            let tmp = self.signature.text
            let msg = self.message.text
            let addr = updatedString
            if tmp!.trimmingCharacters(in: .whitespaces).length > 0{
                self.verifyMessage(signatures: tmp!, messages: msg!, address: addr!)
            }
            
            
        }
        else if textField == self.message{
            let addr = self.address.text
            if updatedString != nil || updatedString?.trimmingCharacters(in: .whitespaces) != "" || updatedString?.trimmingCharacters(in: .whitespaces).length != 0{
                let tmp = self.signature.text!
                if(tmp.length > 0){
                    print("msg1")
                    self.verifyMessage(signatures: tmp, messages: updatedString!, address: addr!)
                }
                
                
                
            }
            else{
                updatedString = ""
                print("msg 2")
                let tmp = self.signature.text!
                if(tmp.length > 0){
                    self.verifyMessage(signatures: tmp, messages: updatedString!, address: addr!)
                }
            }
            
        }
        else if textField == self.signature{
            if updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == ""{
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
                let tmp = updatedString
            let addr = self.address.text
            self.verifyMessage(signatures: tmp!, messages: self.message.text!, address: addr!)
            self.checkCopyBtn(signatured: tmp!)
            return true
            
        }
        if(self.addressPass) {
            if self.sigPass && (self.signature.text!.trimmingCharacters(in: .whitespaces).length) < 1{
                print(signature.text!)
                print(self.signature.text?.length ?? "1000000")
                print("enable button me")
                self.signMsgBtn.isEnabled = true
                self.signMsgBtn.backgroundColor = UIColor(hex: "#007AFF")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
            }
            else{
                
                self.signMsgBtn.isEnabled = false
                self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
            }
            
        }
        else{
            print(signature.text!)
           
            print("disable button main aux")
            
            self.signMsgBtn.isEnabled = false
            self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
            self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
        }
        self.checkCopyBtn(signatured: self.signature.text!)
        
        
        return true
    }
    func verifyMessage(signatures: String,messages :String, address:String){
        let addressd = address.trimmingCharacters(in: .whitespaces)
        let message = messages
        let signatured = signatures
        let retV = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        
        if (signatured == ""){
            signatureError.text = ""
            self.sigPass = true
            return
        }
        if(mobilewallet.isAddressValid(addressd)){
            do{
                try mobilewallet.verifyMessage(addressd, message: message, signatureBase64: signatured, ret0_: retV)
                if(retV[0]).boolValue{
                    self.signatureError.text = "This signature verifies against the message and address."
                    self.signatureError.textColor = UIColor(hex: "#007AFF")
                    self.signMsgBtn.isEnabled = false
                    self.sigPass = true
                    self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                    self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                    return
                }
                else{
                    self.signatureError.text = "This signature  does not verify against the message and address."
                    self.signatureError.textColor = UIColor.red
                    self.signMsgBtn.isEnabled = false
                    self.sigPass = false
                    self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                    self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                    return
                }
            }
            catch {
                self.signatureError.text = ""
                self.signatureError.textColor = UIColor.red
                self.signMsgBtn.isEnabled = false
                self.sigPass = false
                self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
                self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
                self.signatureError.text = "This signature  does not verify against the message and address."
                
            }
        }
        else{
            self.signatureError.text = "This signature  does not verify against the message and address."
            self.signatureError.textColor = UIColor.red
            self.signMsgBtn.isEnabled = false
            self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
            self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
        }
        return
    }
    private func askPassword() {
        
        let alert = UIAlertController(title: "Security", message: "Please enter spending password of your wallet", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        let okAction = UIAlertAction(title: "Proceed", style: .default) { _ in
            let tfPasswd = alert.textFields![0] as UITextField
            self.SignMsg(pass: tfPasswd.text!)
            alert.dismiss(animated: false, completion: nil)
            
           
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.dismiss(animated: false, completion: nil)
            
        }
        alert.addAction(CancelAction)
        alert.addAction(okAction)
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func SignMsg(pass:String){
        let address = self.address.text
        let message = self.message.text
        let finalPassphrase = pass as NSString
        let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
        print(address!)
        print(message!)
        print(finalPassphraseData)
        
        do{
            print("about to enter")
            let signature = try mobilewallet.signMessage(finalPassphraseData, address: address, message: message)
            print("not yet")
            print(MobilewalletEncodeHex(signature))
            self.signature.text = signature.base64EncodedString()
            self.verifyMessage(signatures: self.signature.text!, messages: message!, address: address!)
            self.checkCopyBtn(signatured: self.signature.text!)
        }
        catch{
            DispatchQueue.main.async {
            let alertController = UIAlertController(title: "", message: "Password entered was not valid.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            }
           
            
        }
        
    }
    func checkCopyBtn(signatured:String){
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
            let info = "Address: \(self.address.text ?? "") \nMessage: \(self.message.text ?? "") \nSignature: \(self.signature.text ?? "")"
            UIPasteboard.general.string = info
            
            //Alert
            let alertController = UIAlertController(title: "", message: "Copied successfully.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
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
