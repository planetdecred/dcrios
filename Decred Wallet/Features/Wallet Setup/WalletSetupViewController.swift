//
//  WalletSetupViewController.swift
//  Decred Wallet

/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class WalletSetupViewController: WalletSetupBaseViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewWalletCreation" {
            Settings.setValue(true, for: Settings.Keys.NewWalletSetUp)
        }
    }
    
    @IBAction func restoreWallet(_ sender: Any) {
        let recoverVC = Storyboards.RecoverExistingWallet.instantiateViewController(for: RecoverExistingWalletViewController.self)
        Settings.setValue(false, for: Settings.Keys.NewWalletSetUp)
        self.navigationController?.pushViewController(recoverVC, animated: true)
    }
}
