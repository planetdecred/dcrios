//
//  WalletSettingsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class WalletSettingsViewController: UIViewController {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var useFingerprintSwitch: UISwitch!
    @IBOutlet weak var incomingTransactionsNotificationsSetting: UIButton!
    
    var walletID: Int!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func changeSpendingPINPassword(_ sender: Any) {
    }
    
    @IBAction func changeIncomingTransactionsNotificationsSetting(_ sender: Any) {
    }
    
    @IBAction func removeWalletFromDevice(_ sender: Any) {
    }
}
