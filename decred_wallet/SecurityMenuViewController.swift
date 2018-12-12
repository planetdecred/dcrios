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
    var sigPass  = false
    var mobilewallet :MobilewalletLibWallet!
    override func viewDidLoad() {
        super.viewDidLoad()
        mobilewallet = SingleInstance.shared.wallet
        self.address.delegate = self
        self.signature.delegate = self
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
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if textField == self.address{
            if updatedString == nil || updatedString?.trimmingCharacters(in: .whitespaces) == ""{
                self.addressError.text = ""
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
        }
        else if textField == self.message{
            if textField.text != nil && textField.text?.trimmingCharacters(in: .whitespaces) != ""{
                return true
            }
            
        }
        else if textField == self.signature{
            if updatedString == nil && updatedString?.trimmingCharacters(in: .whitespaces) == ""{
                self.signatureError.text = ""
                return true
            }
            else{
                let tmp = updatedString
                self.verifyMessage(signatures: tmp!)
                print("verified")
            }
            
            
        }
        if(addressPass && ((self.signature?.text?.trimmingCharacters(in: .whitespaces)) == "")){
            self.signMsgBtn.isEnabled = true
            self.signMsgBtn.backgroundColor = UIColor(hex: "#007AFF")
            self.signMsgBtn.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        }
        else{
            self.signMsgBtn.isEnabled = false
            self.signMsgBtn.backgroundColor = UIColor(hex: "#F2F4F3")
            self.signMsgBtn.setTitleColor(UIColor(hex: "#434343"), for: .normal)
        }
        
        return true
    }
    func verifyMessage(signatures: String){
        let address = self.address.text?.trimmingCharacters(in: .whitespaces)
        let message = self.message.text
        let signatured = signatures
        let retV = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        
        if (signatured == ""){
            signatureError.text = ""
            return
        }
        if(mobilewallet.isAddressValid(address)){
            do{
                try mobilewallet.verifyMessage(address, message: message, signatureBase64: signatured, ret0_: retV)
                if(retV[0]).boolValue{
                    self.signatureError.text = "This signature verifies against the message and address."
                    self.signatureError.textColor = UIColor(hex: "#007AFF")
                }
                else{
                    self.signatureError.text = "This signature  does not verify against the message and address."
                    self.signatureError.textColor = UIColor.red
                }
            }
            catch {
                self.signatureError.text = "This signature  does not verify against the message and address."
                self.signatureError.textColor = UIColor.red
            }
        }
        else{
            self.signatureError.text = "This signature  does not verify against the message and address."
            self.signatureError.textColor = UIColor.red
        }
    }
    @IBAction func signMessage(_ sender: UIButton) {
        
    }
    
    @IBAction func Copy(_ sender: Any) {
        
    }
}
