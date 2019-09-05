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
    @IBOutlet weak var restoreWallet: UILabel!
    @IBOutlet weak var createWallet: UILabel!
    @IBOutlet weak var build: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createWallet.text = LocalizedStrings.createNewWallet
        restoreWallet.text = LocalizedStrings.restoreExistingWallet
        infoText.text = LocalizedStrings.createOrRecoverWallet
        
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        let netType = BuildConfig.IsTestNet ? "testnet" : BuildConfig.NetType
        build?.text = "build \(netType) " + dateformater.string(from: AppDelegate.compileDate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewWalletCreation" {
            Settings.setValue(true, for: Settings.Keys.NewWalletSetUp)
        } else if segue.identifier == "toWalletRestore" {
            Settings.setValue(false, for: Settings.Keys.NewWalletSetUp)
        }
    }
}
