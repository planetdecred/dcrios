//
//  WalletSetupBaseController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 25/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import UIKit

// WalletSetupBaseViewController is extended by ...
class WalletSetupBaseViewController: UIViewController {
    
    // finalizeWalletSetup is called by ...
    func finalizeWalletSetup(_ seed: String, _ pinOrPassword: String, _ securityType: String) {
        let progressHud = showProgressHud(with: "creating wallet...")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let this = self else { return }
            
            do {
                if SingleInstance.shared.wallet == nil {
                    return
                }
                
                let wallet = SingleInstance.shared.wallet!
                try wallet.createWallet(password, seedMnemonic: seed)
                try wallet.unlock(password.data(using: .utf8))
                
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    UserDefaults.standard.set(securityType, forKey: "spendingSecureType")
                    createMainWindow()
                    this.dismiss(animated: true, completion: nil)
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    this.showWalletSetupError(error: error)
                }
            }
        }
    }
    
    func showWalletSetupError(error:Error) {
        let alert = UIAlertController(title: "Warning", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
