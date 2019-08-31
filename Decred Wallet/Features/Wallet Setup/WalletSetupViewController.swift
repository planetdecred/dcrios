//
//  WalletSetupViewController.swift
//  Decred Wallet

/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class WalletSetupViewController: WalletSetupBaseViewController {
    @IBAction func createWalletBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.toNewWalletCreation.rawValue, sender: self)
    }
    
    @IBAction func restoreWalletBtnTapped(_ sender: UIButton){
        performSegue(withIdentifier: Segues.toWalletRestore.rawValue, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toNewWalletCreation.rawValue {
            Settings.setValue(true, for: Settings.Keys.NewWalletSetUp)
        } else if segue.identifier == Segues.toWalletRestore.rawValue {
            Settings.setValue(false, for: Settings.Keys.NewWalletSetUp)
        }
    }
}
