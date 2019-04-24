//
//  PasswordSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import PasswordStrength
import JGProgressHUD

class PasswordSetupViewController: UIViewController, SeedCheckupProtocol, UITextFieldDelegate, StartUpPasswordProtocol,PinEnteredProtocol{
    var pinInput: String?
    
    
    var senders: String?
    var seedToVerify: String?
    var pass_pinToVerify: String?
    
    @IBOutlet weak var confirmPassLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var lbMatchIndicator: UILabel!
    @IBOutlet weak var pbPasswordStrength: UIProgressView!
    @IBOutlet weak var lbPasswordStrengthLabel: UILabel!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    
    let passwordStrengthMeasurer = MEPasswordStrength()
    var progressHud : JGProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfPassword.delegate = self
        tfConfirmPassword.delegate = self
        //lbMatchIndicator.isHidden = true
        // pbPasswordStrength.isHidden = true
        // lbPasswordStrengthLabel.isHidden = true
        okBtn.layer.cornerRadius = 5
        tfConfirmPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if (self.seedToVerify != nil) {
            senders = "seed"
        }
        setScreenFont()
        setHeader()
    }
    
    func onEncrypt() {
        
        progressHud = showProgressHud(with: "creating wallet...")
        
        let seed = self.seedToVerify!
        let pass = self.tfPassword!.text
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                if SingleInstance.shared.wallet == nil {
                    return
                }
                
                let wallet = SingleInstance.shared.wallet!
                
                try wallet.createWallet(pass, seedMnemonic: seed)
                try wallet.unlock(pass!.data(using: .utf8))
                DispatchQueue.main.async {
                    self!.progressHud!.dismiss()
                    self!.pinInput = pass
                    UserDefaults.standard.set("PASSWORD", forKey: "spendingSecureType")
                    createMainWindow()
                    this.dismiss(animated: true, completion: nil)
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    self!.progressHud!.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    
    func SetstartupPin_pas(){
        progressHud = showProgressHud(with: "Securing wallet...")
        
        let finalkeyData = ("public" as NSString).data(using: String.Encoding.utf8.rawValue)!
        let finalkeypassData = (self.tfPassword!.text! as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeyData, newPass: finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    UserDefaults.standard.set(true, forKey: "secure_wallet")
                    UserDefaults.standard.setValue("PASSWORD", forKey: "securitytype")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    
    func ChangeSpendingPass(){
        progressHud = showProgressHud(with: "Changing spending password...")
        
        let finalkeyData = (pass_pinToVerify! as NSString).data(using: String.Encoding.utf8.rawValue)!
        let finalkeypassData = (self.tfPassword!.text! as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePrivatePassphrase(finalkeyData, newPass: finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    UserDefaults.standard.setValue("PASSWORD", forKey: "spendingSecureType")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    func ChangeStartupPass(){
        progressHud = showProgressHud(with: "Changing startup password...")
        
        let finalkeyData = (pass_pinToVerify! as NSString).data(using: String.Encoding.utf8.rawValue)!
        let finalkeypassData = (self.tfPassword!.text! as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeyData, newPass: finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    UserDefaults.standard.set(true, forKey: "secure_wallet")
                    UserDefaults.standard.setValue("PASSWORD", forKey: "securitytype")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.dismiss()
                    this.showError(error: error)
                }
            }
        }
    }
    func showError(error:Error){
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: {self.progressHud!.dismiss()})
    }
    
    @objc func textFieldDidChange(_: NSObject){
        if self.tfPassword.text == self.tfConfirmPassword.text {
            self.lbMatchIndicator.textColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1)
            self.lbMatchIndicator.text = "PASSWORDS MATCH"
            self.okBtn.isEnabled = true
            self.okBtn.backgroundColor = UIColor(hex: "#007AFF")
            self.okBtn.setTitleColor(UIColor.white, for: .normal)
        }else{
            self.lbMatchIndicator.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.lbMatchIndicator.text = "PASSWORDS DO NOT MATCH"
            self.okBtn.isEnabled = false
            self.okBtn.backgroundColor = UIColor(hex: "#E6EAED")
            self.okBtn.setTitleColor(UIColor(hex: "#000000", alpha: 0.61), for: .normal)
        }
    }
    @IBAction func creayePassBtn(_ sender: Any) {
        self.ActionButton()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.tag == 5) { //password
            pbPasswordStrength.progress = passwordStrengthMeasurer.strength(forPassword: textField.text) as! Float
            pbPasswordStrength.progressTintColor = passwordStrengthMeasurer.strengthColor(forPassword: textField.text)
            pbPasswordStrength.isHidden = false
            lbPasswordStrengthLabel.isHidden = false
        } else {
            lbMatchIndicator.isHidden = false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.ActionButton()
    }
    
    func ActionButton() -> Bool{
        guard self.tfPassword.text == self.tfConfirmPassword.text else {
            self.showMessageDialog(title: "Error", message: "Password does not match")
            return false
        }
        let tmpsender = self.senders
        if (tmpsender == "settings") {
            SetstartupPin_pas()
        }
        else if (tmpsender == "settingsChangeSpending") {
            ChangeSpendingPass()
        }else if (tmpsender == "settingsChangeStartup") {
            ChangeStartupPass()
        }
        else {
            onEncrypt()
        }
        return true
    }
    
    func dismissView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setHeader(){
        if (senders == "launcher") {
            headerText.text = "Enter Startup Password"
        } else if (senders == "settings") {
            if (UserDefaults.standard.bool(forKey: "secure_wallet")) {
                headerText.text = "Enter Current Password"
            } else {
                headerText.text = "Create Startup Password"
            }
        }
        else if (senders == "settingsChangeSpending") {
            headerText.text = "Change Spending Password"
        }
        else if (senders == "settingsChangeStartup") {
            headerText.text = "Change Startup Password"
        }
        else {
            headerText.text = "Create Spending Password"
        }
    }
    func setScreenFont(){
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //iPhone 5 or 5S or 5C
                self.setFontSize(confirmPassLabeTxt: 13, passwordLabelTxt: 13, lbMatchIndicatorTxt: 13, lbPasswordStrengthLabelTxt: 13, okBtnTxt: 13, headerTxt: 18, tfPasswordTxt: 13, tfConfirmPasswordTxt: 13)
                break
            case 1334:
                // iPhone 6/6S/7/8
                self.setFontSize(confirmPassLabeTxt: 15, passwordLabelTxt: 15, lbMatchIndicatorTxt: 15, lbPasswordStrengthLabelTxt: 15, okBtnTxt: 15, headerTxt: 20, tfPasswordTxt: 15, tfConfirmPasswordTxt: 15)
                
                break
            case 2208:
                //iPhone 6+/6S+/7+/8+
                self.setFontSize(confirmPassLabeTxt: 17, passwordLabelTxt: 17, lbMatchIndicatorTxt: 17, lbPasswordStrengthLabelTxt: 17, okBtnTxt: 17, headerTxt: 22, tfPasswordTxt: 17, tfConfirmPasswordTxt: 17)
                break
            case 2436:
                // iPhone X
                self.setFontSize(confirmPassLabeTxt: 15, passwordLabelTxt: 15, lbMatchIndicatorTxt: 15, lbPasswordStrengthLabelTxt: 15, okBtnTxt: 15, headerTxt: 20, tfPasswordTxt: 15, tfConfirmPasswordTxt: 15)
                
                break
            default: break
                // print("unknown")
            }
        }
        else if UIDevice().userInterfaceIdiom == .pad{
            switch UIScreen.main.nativeBounds.height {
            case 2048:
                // iPad Pro (9.7-inch)/ iPad Air 2/ iPad Mini 4
                self.setFontSize(confirmPassLabeTxt: 27, passwordLabelTxt: 27, lbMatchIndicatorTxt: 27, lbPasswordStrengthLabelTxt: 27, okBtnTxt: 27, headerTxt: 42, tfPasswordTxt: 27, tfConfirmPasswordTxt: 27)
                print("ipad air")
                break
            case 2224:
                //iPad Pro 10.5-inch
                self.setFontSize(confirmPassLabeTxt: 29, passwordLabelTxt: 29, lbMatchIndicatorTxt: 29, lbPasswordStrengthLabelTxt: 29, okBtnTxt: 29, headerTxt: 44, tfPasswordTxt: 29, tfConfirmPasswordTxt: 29)
                print("ipad air 10inch")
                break
            case 2732:
                // iPad Pro 12.9-inch
                self.setFontSize(confirmPassLabeTxt: 37, passwordLabelTxt: 37, lbMatchIndicatorTxt: 37, lbPasswordStrengthLabelTxt: 37, okBtnTxt: 37, headerTxt: 52, tfPasswordTxt: 37, tfConfirmPasswordTxt: 37)
                break
            default:
                print("unknown")
                print(UIScreen.main.nativeBounds.height)
                break
            }
        }
    }
    func setFontSize(confirmPassLabeTxt: CGFloat, passwordLabelTxt: CGFloat, lbMatchIndicatorTxt: CGFloat,lbPasswordStrengthLabelTxt: CGFloat, okBtnTxt: CGFloat,headerTxt: CGFloat,tfPasswordTxt: CGFloat, tfConfirmPasswordTxt : CGFloat){
        self.confirmPassLabel.font = confirmPassLabel.font?.withSize(confirmPassLabeTxt)
        self.passwordLabel.font = passwordLabel.font?.withSize(passwordLabelTxt)
        self.lbMatchIndicator.font = lbMatchIndicator.font?.withSize(lbMatchIndicatorTxt)
        self.lbPasswordStrengthLabel.font = lbPasswordStrengthLabel.font.withSize(lbPasswordStrengthLabelTxt)
        self.headerText.font = headerText.font.withSize(headerTxt)
        self.okBtn.titleLabel?.font = .systemFont(ofSize: okBtnTxt)
        self.tfPassword.font = .systemFont(ofSize: tfPasswordTxt)
        self.tfConfirmPassword.font = .systemFont(ofSize: tfConfirmPasswordTxt)
    }
}
