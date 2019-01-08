//
//  PasswordSetupViewController.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit
import PasswordStrength
import MBProgressHUD

class PasswordSetupViewController: UIViewController, SeedCheckupProtocol,UITextFieldDelegate,StartUpPasswordProtocol{
    var senders: String?
    var seedToVerify: String?
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var lbMatchIndicator: UILabel!
    @IBOutlet weak var pbPasswordStrength: UIProgressView!
    
    @IBOutlet weak var lbPasswordStrengthLabel: UILabel!
    var progressHud:MBProgressHUD?
    let passwordStrengthMeasurer = MEPasswordStrength()
    @IBOutlet weak var headerText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfPassword.delegate = self
        tfConfirmPassword.delegate = self
        lbMatchIndicator.isHidden = true
        pbPasswordStrength.isHidden = true
        lbPasswordStrengthLabel.isHidden = true
        progressHud = MBProgressHUD(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        view.addSubview(progressHud!)
        tfConfirmPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        if self.seedToVerify != nil{
            senders = "seed"
            
        }
        setHeader()

    }

    func onEncrypt() {
        self.progressHud?.show(animated: true)
        self.progressHud?.label.text = "creating wallet..."
        let seed = self.seedToVerify!
        let pass = self.tfPassword!.text
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                if SingleInstance.shared.wallet == nil {
                    return
                }
                try SingleInstance.shared.wallet?.createWallet(pass, seedMnemonic: seed)
                DispatchQueue.main.async {
                    this.progressHud?.hide(animated: true)
                    UserDefaults.standard.set(pass, forKey: "password")
                    print("wallet created")
                    createMainWindow()
                    this.dismiss(animated: true, completion: nil)
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.hide(animated: true)
                    this.showError(error: error)
                }
            }
        }
    }
    
    func SetstartupPin_pas(){
        self.progressHud?.show(animated: true)
        self.progressHud?.label.text = "securing wallet..."
        let key = "public"
        let finalkey = key as NSString
        let finalkeyData = finalkey.data(using: String.Encoding.utf8.rawValue)!
        let pass = self.tfPassword!.text
        
        let finalpass = pass! as NSString
        let finalkeypassData = finalpass.data(using: String.Encoding.utf8.rawValue)!
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                try SingleInstance.shared.wallet?.changePublicPassphrase(finalkeyData, newPass: finalkeypassData)
                DispatchQueue.main.async {
                    this.progressHud?.hide(animated: true)
                   
                    print("passSet")
                    UserDefaults.standard.set(true, forKey: "secure_wallet")
                    UserDefaults.standard.setValue("PASSWORD", forKey: "securitytype")
                    UserDefaults.standard.synchronize()
                    self?.dismissView()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.hide(animated: true)
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
        present(alert, animated: true, completion: {self.progressHud?.hide(animated: false)})
    }
    
    @objc func textFieldDidChange(_: NSObject){
        if self.tfPassword.text == self.tfConfirmPassword.text {
            self.lbMatchIndicator.textColor = #colorLiteral(red: 0.2537069321, green: 0.8615272641, blue: 0.7028611302, alpha: 1)
            self.lbMatchIndicator.text = "PASSWORDS MATCH"
        }else{
            self.lbMatchIndicator.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            self.lbMatchIndicator.text = "PASSWORDS NOT MATCH"
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 5 { //password
            pbPasswordStrength.progress = passwordStrengthMeasurer.strength(forPassword: textField.text) as! Float
            pbPasswordStrength.progressTintColor = passwordStrengthMeasurer.strengthColor(forPassword: textField.text)
            pbPasswordStrength.isHidden = false
            lbPasswordStrengthLabel.isHidden = false
        }else{
            lbMatchIndicator.isHidden = false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tmpsender = self.senders
        if tmpsender == "settings"{
            SetstartupPin_pas()
        }
        else{
            onEncrypt()
        }
        
        return true
    }
    func dismissView() {
        self.navigationController?.popViewController(animated: true)
    }
    func setHeader(){
        if senders == "launcher"{
            
            headerText.text = "Enter Startup Password"
                
            
        }
        else if senders == "settings"{
            if (UserDefaults.standard.bool(forKey: "secure_wallet")){
                headerText.text = "Enter Current Password"
                
            }
            else{
                headerText.text = "Create Startup Password"
                
            }
        }
        else{
            headerText.text = "Create Spending Password"
        }
    }
}

