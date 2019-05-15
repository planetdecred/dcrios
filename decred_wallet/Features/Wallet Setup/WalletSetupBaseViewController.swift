//
//  WalletSetupBaseController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 25/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import UIKit

class WalletSetupBaseViewController: UIViewController {
    static func instantiate() -> Self {
        return Storyboards.WalletSetup.instantiateViewController(for: self)
    }
    
    func finalizeWalletSetup(_ seed: String, _ pinOrPassword: String, _ securityType: String) {
        let progressHud = Utils.showProgressHud(withText: "Setting up wallet...")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            guard let wallet = WalletLoader.wallet else { return }
            
            do {
                try wallet.createWallet(pinOrPassword, seedMnemonic: seed)
                try wallet.unlock(pinOrPassword.utf8Bits)
                
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    UserDefaults.standard.set(securityType, forKey: GlobalConstants.SettingsKeys.SpendingPassphraseSecurityType)
                    NavigationMenuViewController.setupMenuAndLaunchApp(isNewWallet: true)
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    this.showOkAlert(message: error.localizedDescription, title: "Error setting up wallet")
                }
            }
        }
    }
}
