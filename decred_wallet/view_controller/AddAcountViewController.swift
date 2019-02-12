//
//  AddAcountViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 31/10/2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit



class AddAcountViewController: UIViewController {
    @IBOutlet weak var passphrase: UITextField!
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var createBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createBtn.layer.cornerRadius = 6
        // Do any additional setup after loading the view.
    }
    
    @IBAction func createFnc(_ sender: Any) {
        if (accountName.text?.length)! < 1{
            Info(msg: "Please input an account name")
            return
        }
        let name = accountName.text
        let pass = passphrase.text
        if(!(name!.isEmpty) || (pass!.isEmpty)){
            let finalPassphrase = pass! as NSString
            let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
            DispatchQueue.global(qos: .userInitiated).async {
            do {
               try SingleInstance.shared.wallet?.nextAccount(name, privPass: finalPassphraseData)
                DispatchQueue.main.async {
              
                self.dismiss(animated: true, completion: nil)
                }
                
            }catch{
                DispatchQueue.main.async {
                    self.showError(error: error)
                print("error")
                }
            }
            }
                
            
        }
        else{
            
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
