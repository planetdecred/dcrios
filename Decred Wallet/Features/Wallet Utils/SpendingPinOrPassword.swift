//
//  PrivatePassphrase.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

struct SpendingPinOrPassword {
    static func change(sender vc: UIViewController) {
        self.promptForCurrentPinOrPassword(vc, afterUserEntersPinOrPassword: { (currentPinOrPassword: String, completionDelegate: SecurityRequestCompletionDelegate?) in
            completionDelegate?.securityCodeProcessed(true, nil)
            self.promptForNewPinOrPassword(vc, currentPinOrPassword: currentPinOrPassword)
        })
    }
    
    private static func promptForCurrentPinOrPassword(_ vc: UIViewController, afterUserEntersPinOrPassword: @escaping (String, SecurityRequestCompletionDelegate?) -> Void) {
        // show the appropriate vc to read current pin or password
        if self.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            let requestPasswordVC = RequestPasswordViewController.instantiate()
            requestPasswordVC.securityFor = LocalizedStrings.current
            requestPasswordVC.prompt = LocalizedStrings.enterCurrentSpendingPassword
            requestPasswordVC.onUserEnteredSecurityCode = afterUserEntersPinOrPassword
            vc.present(requestPasswordVC, animated: true)
        } else {
            let requestPinVC = RequestPinViewController.instantiate()
            requestPinVC.securityFor = LocalizedStrings.current
            requestPinVC.showCancelButton = true
            requestPinVC.onUserEnteredSecurityCode = afterUserEntersPinOrPassword
            requestPinVC.prompt = LocalizedStrings.enterCurrentSpendingPIN
            vc.present(requestPinVC, animated: true)
        }
    }
    
    private static func promptForNewPinOrPassword(_ vc: UIViewController, currentPinOrPassword: String) {
        // init secutity vc to use in getting new spending password or pin from user
        let securityVC = SecurityViewController.instantiate()
        securityVC.securityFor = LocalizedStrings.spending
        securityVC.initialSecurityType = self.currentSecurityType()
        
        securityVC.onUserEnteredPinOrPassword = { (newPinOrPassword, securityType, completionDelegate) in
            self.changeWalletSpendingPassphrase(vc, current: currentPinOrPassword, new: newPinOrPassword, type: securityType, completionDelegate: completionDelegate)
        }
        vc.present(securityVC, animated: true, completion: nil)
    }
    
    private static func changeWalletSpendingPassphrase(_ vc: UIViewController, current currentPassphrase: String, new newPassphrase: String, type securityType: String, completionDelegate: SecurityRequestCompletionDelegate?) {
        let oldPrivatePass = (currentPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        let newPrivatePass = (newPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let passphraseType = securityType == SecurityViewController.SECURITY_TYPE_PASSWORD ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
                
                try WalletLoader.shared.multiWallet.changePrivatePassphrase(forWallet: WalletLoader.shared.wallet!.id_,
                                                                                 oldPrivatePassphrase: oldPrivatePass,
                                                                                 newPrivatePassphrase: newPrivatePass,
                                                                                 privatePassphraseType: passphraseType)
                DispatchQueue.main.async {
                    completionDelegate?.securityCodeProcessed(true, nil)
                    Settings.setValue(securityType, for: Settings.Keys.SpendingPassphraseSecurityType)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completionDelegate?.securityCodeProcessed(true, nil)
                    vc.showOkAlert(message: error.localizedDescription, title: LocalizedStrings.error)
                }
            }
        }
    }
    
    static func currentSecurityType() -> String? {
        return Settings.readOptionalValue(for: Settings.Keys.SpendingPassphraseSecurityType)
    }
}
