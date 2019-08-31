//
//  WalletSetupViewController.swift
//  Decred Wallet

/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class WalletSetupViewController: WalletSetupBaseViewController {
    @IBOutlet weak var infoText: UILabel!
    
    @IBOutlet weak var createWalletBtn: UIButton!
    @IBOutlet weak var restoreWalletBtn: UIButton!
    
    // Action on create wallet tap
    @IBAction func createTapped(_ sender: UIButton){
        performSegue(withIdentifier: "toNewWalletCreation", sender: self)
    }
    
    // Action on restore wallet tap
    @IBAction func restoreTapped(_ sender: UIButton){
        performSegue(withIdentifier: "toWalletRestore", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        createWalletBtn.layer.cornerRadius = 7
        restoreWalletBtn.layer.cornerRadius = 7
        
        createWalletBtn.titleLabel?.text = LocalizedStrings.createNewWallet
        restoreWalletBtn.titleLabel?.text = LocalizedStrings.restoreExistingWallet
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toNewWalletCreation.rawValue {
            Settings.setValue(true, for: Settings.Keys.NewWalletSetUp)
        } else if segue.identifier == Segues.toWalletRestore.rawValue {
            Settings.setValue(false, for: Settings.Keys.NewWalletSetUp)
        }
    }
}
