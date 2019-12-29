//
//  PrivatePassphrase.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

struct SpendingPinOrPassword {
    static func change(sender vc: UIViewController) {
        self.promptForCurrentPinOrPassword(vc, afterUserEntersPinOrPassword: { (currentPinOrPassword: String, securityRequestVC: SecurityRequestBaseViewController?) in
            securityRequestVC?.dismissView()
            self.promptForNewPinOrPassword(vc, currentPinOrPassword: currentPinOrPassword)
        })
    }
    
    private static func promptForCurrentPinOrPassword(_ vc: UIViewController, afterUserEntersPinOrPassword: @escaping (String, SecurityRequestBaseViewController?) -> Void) {
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
        
        securityVC.onUserEnteredPinOrPassword = { (newPinOrPassword, securityType, securityRequestVC) in
            self.changeWalletSpendingPassphrase(vc, current: currentPinOrPassword, new: newPinOrPassword, type: securityType, securityRequestVC: securityRequestVC)
        }
        vc.present(securityVC, animated: true, completion: nil)
    }
    
    private static func changeWalletSpendingPassphrase(_ vc: UIViewController, current currentPassphrase: String, new newPassphrase: String, type securityType: String, securityRequestVC: SecurityRequestBaseViewController?) {
        let oldPrivatePass = (currentPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        let newPrivatePass = (newPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try AppDelegate.walletLoader.wallet?.changePrivatePassphrase(oldPrivatePass, newPass: newPrivatePass)
                DispatchQueue.main.async {
                    securityRequestVC?.dismissView()
                    Settings.setValue(securityType, for: Settings.Keys.SpendingPassphraseSecurityType)
                }
            } catch let error {
                DispatchQueue.main.async {
                    securityRequestVC?.dismissView()
                    vc.showOkAlert(message: error.localizedDescription, title: LocalizedStrings.error)
                }
            }
        }
    }
    
    static func currentSecurityType() -> String? {
        return Settings.readOptionalValue(for: Settings.Keys.SpendingPassphraseSecurityType)
    }
}
