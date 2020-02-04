//
//  WalletSetupViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletSetupViewController: UIViewController {
    @IBAction func createNewwallet(_ sender: Any) {
        Security.spending(initialSecurityType: .password)
            .requestNewCode(sender: self, isChangeAttempt: false) { pinOrPassword, type, completion in
                
                WalletLoader.shared.createWallet(spendingPinOrPassword: pinOrPassword, securityType: type) {
                    createWalletError in
                    
                    if createWalletError != nil {
                        completion?.displayError(errorMessage: createWalletError!.localizedDescription)
                    } else {
                        completion?.dismissDialog()
                        NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: true)
                    }
                }
        }
    }
}
