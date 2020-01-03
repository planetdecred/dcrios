//
//  WalletSetupBaseController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class WalletSetupBaseViewController: UIViewController {
    static func instantiate() -> Self {
        return Storyboards.WalletSetup.instantiateViewController(for: self)
    }
    
    func finalizeWalletSetup(_ seed: String, _ pinOrPassword: String, _ securityType: String, _ completionDelegate: SecurityRequestCompletionDelegate?) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            let multiwallet = AppDelegate.walletLoader.multiWallet
            let privatePassphraseType = securityType == SecurityViewController.SECURITY_TYPE_PASSWORD ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
            
            do {
                try multiwallet?.createNewWallet(pinOrPassword, privatePassphraseType: privatePassphraseType)
                
                DispatchQueue.main.async {
                    Settings.setValue(securityType, for: Settings.Keys.SpendingPassphraseSecurityType)

                    if Settings.newWalletSetUp {
                        Settings.setValue(seed, for: Settings.Keys.Seed)
                        Settings.setValue(false, for: Settings.Keys.SeedBackedUp)
                        NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: true)
                    } else {
                        Settings.setValue(true, for: Settings.Keys.SeedBackedUp)
                        completionDelegate?.securityCodeProcessed(true, nil)
                        this.performSegue(withIdentifier: "recoverySuccess", sender: self)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    completionDelegate?.securityCodeProcessed(false, error.localizedDescription)
                }
            }
        }
    }
}
