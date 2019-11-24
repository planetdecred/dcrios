//
//  WalletSetupBaseController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class WalletSetupBaseViewController: UIViewController {
    static func instantiate() -> Self {
        return Storyboards.WalletSetup.instantiateViewController(for: self)
    }
    
    func finalizeWalletSetup(_ seed: String, _ pinOrPassword: String, _ securityType: String) {
        let progressHud = Utils.showProgressHud(withText: LocalizedStrings.settingUpWallet)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            guard let wallet = AppDelegate.walletLoader.wallet else { return }
            
            do {
                try wallet.createWallet(pinOrPassword, seedMnemonic: seed)
                try wallet.unlock(pinOrPassword.utf8Bits)
                
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    Settings.setValue(securityType, for: Settings.Keys.SpendingPassphraseSecurityType)
                    //NavigationMenuViewController.setupMenuAndLaunchApp(isNewWallet: true)
                    self?.performSegue(withIdentifier: "recoverySuccess", sender: nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    this.showOkAlert(message: error.localizedDescription, title: LocalizedStrings.errorSettingUpWallet)
                }
            }
        }
    }
}
