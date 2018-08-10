//
//  WalletSetupViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class WalletSetupViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btn_create_wallet(_ sender: Any) {
        
    }
    @IBAction func btn_recover_wallet(_ sender: Any) {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let recoverController = story.instantiateViewController(withIdentifier: "RecoverWalletViewController") as! RecoverWalletViewController
        
        self.navigationController?.pushViewController(recoverController, animated: true)
    }
    
}
