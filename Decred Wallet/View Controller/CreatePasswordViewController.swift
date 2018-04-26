//
//  CreatePasswordViewController.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 26.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import UIKit
import MBProgressHUD

class CreatePasswordViewController: UIViewController, SeedCheckupProtocol {
    var seedToVerify: String?
    var progressHud: MBProgressHUD?
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfVerifyPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressHud = MBProgressHUD(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        view.addSubview(progressHud!)
    }
    
    @IBAction func onEncrypt(_ sender: Any) {
        do{
            progressHud?.show(animated: true)
            try AppContext.instance.walletManager?.createWallet(tfPassword.text, seedMnemonic: seedToVerify)
            progressHud?.hide(animated: true)
            navigationController?.dismiss(animated: true, completion: nil)
        } catch let error{
            print(error)
        }
        
    }

}
