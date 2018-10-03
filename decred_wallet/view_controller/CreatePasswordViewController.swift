//
//  CreatePasswordViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit
import MBProgressHUD
import Mobilewallet

class CreatePasswordViewController: UIViewController, SeedCheckupProtocol, UITextFieldDelegate {
    var seedToVerify: String?
    var progressHud: MBProgressHUD?
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfVerifyPassword: UITextField!
    @IBOutlet weak var btnEncrypt: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         //IQKeyboardManager.shared().isEnabled = false
        progressHud = MBProgressHUD(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        view.addSubview(progressHud!)
        tfPassword.delegate = self
        tfVerifyPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        SingleInstance.shared.wallet?.runGC()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validatePassword()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validatePassword()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validatePassword(){
        btnEncrypt.isEnabled = (tfPassword.text == tfVerifyPassword.text) && !(tfPassword.text?.isEmpty)!
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onEncrypt(_ sender: Any) {
        self.progressHud?.show(animated: true)
        self.progressHud?.label.text = "creating wallet..."
        print("creating")
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
                print("done")
                return
            } catch let error {
                DispatchQueue.main.async {
                    this.progressHud?.hide(animated: true)
                    this.showError(error: error)
                    print("wallet error")
                    print(error)
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
    
}
