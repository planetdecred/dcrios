//
//  AddAcountViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

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
        let name = accountName.text
        let pass = passphrase.text
        if(!(name!.isEmpty) || (pass!.isEmpty)){
            let finalPassphrase = pass! as NSString
            let finalPassphraseData = finalPassphrase .data(using: String.Encoding.utf8.rawValue)!
            do {
               try SingleInstance.shared.wallet?.nextAccount(name, privPass: finalPassphraseData)
                self.dismiss(animated: true, completion: nil)
                
            }catch{
                print("error")
            }
                
            
        }
        else{
            
        }
        
    }
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
