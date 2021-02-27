//
//  PrivacySetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.


import UIKit
import Dcrlibwallet

class PrivacySetupViewController: UIViewController {
    @IBOutlet weak var setupMixerBtn: Button!
    var wallet: DcrlibwalletWallet!
    @IBOutlet weak var walletName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.walletName.text = self.wallet.name
    }
    @IBAction func dismissView(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func setupMixer(_ sender: Any) {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: wallet.id_) else {
            return
        }
        
        let PrivacySetupTypeVC = PrivacySetupTypeViewController.instantiate(from: .Privacy)
        PrivacySetupTypeVC.wallet = wallet
        self.navigationController?.pushViewController(PrivacySetupTypeVC, animated: true)
    }
}
