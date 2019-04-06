//
//  AddAcountViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD

class AddAcountViewController: UIViewController {
    
    @IBOutlet weak var passphrase: UITextField!
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var createBtnTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createBtn.layer.cornerRadius = 6
        // Do any additional setup after loading the view.
        if UserDefaults.standard.string(forKey: "spendingSecureType") != "PASSWORD" {
            passphrase.isHidden = true
            createBtnTopConstraint.constant = -40
        }
    }
    
    override func onPassCompleted(pass: String) {
        self.addAccountWithPin(pin: pass as NSString)
    }
    
    @IBAction func createFnc(_ sender: Any) {

        if (accountName.text?.length)! < 1{
            Info(msg: "Please input an account name")
            return
        }
        
        let name = accountName.text
        if(!(name!.isEmpty)){
            if UserDefaults.standard.string(forKey: "spendingSecureType") == "PASSWORD" {
                addAccountWithoutPin()
            }else{
                let vc = storyboard!.instantiateViewController(withIdentifier: "PinSetupViewController") as! PinSetupViewController
                vc.isSpendingPassword = true
                vc.showCancel = true
                vc.caller = self
                vc.popViewController = false
                present(vc, animated: true, completion: nil)
                print("pushed")
            }
        }
    }
    
    private func addAccountWithoutPin(){
        let pass = passphrase.text
        if !pass!.isEmpty {
            let passphrase = (self.passphrase.text! as NSString).data(using: String.Encoding.utf8.rawValue)!
            addAccount(passphrase: passphrase)
        }
    }
    
    private func addAccountWithPin(pin: NSString){
        let passphrase = pin.data(using: String.Encoding.utf8.rawValue)!
        addAccount(passphrase: passphrase)
    }
    
    private func addAccount(passphrase: Data){
        let progressHud = JGProgressHUD(style: .light)
        progressHud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 5.0, opacity: 0.2)
        progressHud.textLabel.text = "Creating account..."
        progressHud.show(in: self.view)
        
        let accountName = self.accountName.text!
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try SingleInstance.shared.wallet?.nextAccount(accountName, privPass: passphrase)
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    self.dismiss(animated: true, completion: nil)
                }
            }catch{
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    self.showError(error: error)
                    print("error")
                }
            }
        }
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showError(error:Error){
        let alert = UIAlertController(title: "Error Message", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func Info(msg:String){
        let alert = UIAlertController(title: "Info", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
