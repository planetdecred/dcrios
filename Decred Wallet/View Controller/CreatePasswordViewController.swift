//
//  CreatePasswordViewController.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 26.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import UIKit
import MBProgressHUD
import RxSwift


class CreatePasswordViewController: UIViewController, SeedCheckupProtocol, UITextFieldDelegate {
    var seedToVerify: String?
    var progressHud: MBProgressHUD?
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfVerifyPassword: UITextField!
    @IBOutlet weak var btnEncrypt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressHud = MBProgressHUD(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        view.addSubview(progressHud!)
        tfPassword.delegate = self
        tfVerifyPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validatePassword()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validatePassword()
    }
    
    func validatePassword(){
        btnEncrypt.isEnabled = (tfPassword.text == tfVerifyPassword.text) && !(tfPassword.text?.isEmpty)!
    }
    
    @IBAction func onEncrypt(_ sender: Any) {
        do{
            progressHud?.show(animated: true)
            try AppContext.instance.walletManager?.createWallet(tfPassword.text, seedMnemonic: seedToVerify)
            progressHud?.hide(animated: true)
            UserDefaults.standard.set(true, forKey: "walletCreated")
            navigationController?.dismiss(animated: true, completion: nil)
        } catch let error{
            showError(error: error)
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
