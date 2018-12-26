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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
