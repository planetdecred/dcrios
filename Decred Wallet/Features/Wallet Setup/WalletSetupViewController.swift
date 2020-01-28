//
//  WalletSetupViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletSetupViewController: UIViewController {
    @IBAction func restoreWallet(_ sender: Any) {
        // todo merge RecoverExistingWallet storyboard into WalletSetup storyboard
        // and move all files in `RecoverExistingWallet` group to this `Wallet Setup` group.
        let recoverVC = RecoverExistingWalletViewController.instantiate(from: .RecoverExistingWallet)
        self.navigationController?.pushViewController(recoverVC, animated: true)
    }
    
    @IBAction func createNewwallet(_ sender: Any) {
        Security.spending().requestNewCode(sender: self) { pinOrPassword, type, completion in
            WalletLoader.shared.createWallet(spendingPinOrPassword: pinOrPassword, securityType: type) {
                createWalletError in
                
                if createWalletError != nil {
                    completion?.securityCodeError(errorMessage: createWalletError!.localizedDescription)
                } else {
                    completion?.securityCodeProcessed()
                    NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: true)
                }
            }
        }
    }
}
