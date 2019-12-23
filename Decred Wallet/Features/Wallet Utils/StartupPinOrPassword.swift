//
//  PublicPassphrase.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

struct StartupPinOrPassword {
    static let defaultPublicPassphrase = "public"
    
    static func clear(sender vc: UIViewController, completion: (() -> Void)? = nil) {
        if !self.pinOrPasswordIsSet() {
            // nothing to clear
            completion?()
            return
        }
        
        // pin/password was previously set, get the current pin/password before clearing
        self.promptForCurrentPinOrPassword(vc, afterUserEntersPinOrPassword: { (currentPinOrPassword: String, securityRequestVC: RequestBaseViewController?) in
            self.changeWalletPublicPassphrase(vc, current: currentPinOrPassword, new: nil, securityRequestVC:securityRequestVC, completion: completion)
        })
    }
    
    // alias for set function
    static func change(sender vc: UIViewController, completion: (() -> Void)? = nil) {
        self.set(sender: vc, completion: completion)
    }
    
    static func set(sender vc: UIViewController, completion: (() -> Void)? = nil) {
        if !self.pinOrPasswordIsSet() {
            // pin/password was not previously set
            self.setNewPinOrPassword(vc, currentPinOrPassword: nil, completion: completion)
            return
        }
        
        // pin/password was previously set, get the current pin/password before proceeding
        self.promptForCurrentPinOrPassword(vc, afterUserEntersPinOrPassword: { (currentPinOrPassword: String, securityRequestVC: RequestBaseViewController?) in
            securityRequestVC?.dismissView()
            self.setNewPinOrPassword(vc, currentPinOrPassword: currentPinOrPassword, completion: completion)
        })
    }
    
    static func promptForCurrentPinOrPassword(_ vc: UIViewController, afterUserEntersPinOrPassword: @escaping (String, RequestBaseViewController?) -> Void) {
        // show the appropriate vc to read current pin or password
        if self.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            let requestPasswordVC = RequestPasswordViewController.instantiate()
            requestPasswordVC.securityFor = LocalizedStrings.current
            requestPasswordVC.prompt = LocalizedStrings.promptStartupPassword
            requestPasswordVC.showCancelButton = true
            requestPasswordVC.onUserEnteredCode = afterUserEntersPinOrPassword
            requestPasswordVC.submitBtnText = LocalizedStrings.next
            vc.present(requestPasswordVC, animated: true)
        } else {
            let requestPinVC = RequestPinViewController.instantiate()
            requestPinVC.prompt = LocalizedStrings.promptStartupPIN
            requestPinVC.securityFor = LocalizedStrings.current
            requestPinVC.showCancelButton = true
            requestPinVC.onUserEnteredCode = afterUserEntersPinOrPassword
            vc.present(requestPinVC, animated: true, completion: nil)
        }
    }
    
    private static func setNewPinOrPassword(_ vc: UIViewController, currentPinOrPassword: String?, completion: (() -> Void)? = nil) {
        // init secutity vc to use in getting new password or pin from user
        let securityVC = SecurityViewController.instantiate()
        securityVC.securityFor = LocalizedStrings.startup
        securityVC.initialSecurityType = self.currentSecurityType()
        securityVC.onUserEnteredPinOrPassword = { newPinOrPassword, securityType, securityRequestVC in
            self.changeWalletPublicPassphrase(vc, current: currentPinOrPassword, new: newPinOrPassword, type: securityType, securityRequestVC: securityRequestVC, completion: completion)
        }
        vc.present(securityVC, animated: true, completion: nil)
    }
    
    static func changeWalletPublicPassphrase(_ vc: UIViewController, current currentPassword: String?, new newPinOrPassword: String?, type securityType: String? = nil, securityRequestVC: RequestBaseViewController?, completion: (() -> Void)? = nil) {
        // cannot set new pin/password without a type specified
        if securityType == nil && newPinOrPassword != nil {
            vc.showOkAlert(message: LocalizedStrings.securityTypeNotSpecified, title: LocalizedStrings.invalidRequest)
            return
        }
        
        let currentPublicPassphrase = currentPassword ?? self.defaultPublicPassphrase
        let newPublicPassphrase = newPinOrPassword ?? self.defaultPublicPassphrase
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let oldPublicPass = (currentPublicPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
                let newPublicPass = (newPublicPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
                try AppDelegate.walletLoader.wallet?.changePublicPassphrase(oldPublicPass, newPass: newPublicPass)
                
                DispatchQueue.main.async {
                    if newPinOrPassword == nil {
                        Settings.setValue(false, for: Settings.Keys.IsStartupSecuritySet)
                        Settings.clearValue(for: Settings.Keys.StartupSecurityType)
                    } else {
                        Settings.setValue(true, for: Settings.Keys.IsStartupSecuritySet)
                        Settings.setValue(securityType!, for: Settings.Keys.StartupSecurityType)
                    }
                    securityRequestVC?.dismissView()
                    completion?()
                }
            } catch let error {
                DispatchQueue.main.async {
                    if currentPassword != nil && newPinOrPassword != nil { //change
                        securityRequestVC?.dismissView()
                        vc.showOkAlert(message: error.localizedDescription, title: LocalizedStrings.error)
                    } else {
                        securityRequestVC?.showError(text: error.localizedDescription);
                    }
                    completion?()
                }
            }
        }
    }
    
    static func pinOrPasswordIsSet() -> Bool {
        return Settings.readValue(for: Settings.Keys.IsStartupSecuritySet)
    }
    
    static func currentSecurityType() -> String? {
        return Settings.readOptionalValue(for: Settings.Keys.StartupSecurityType)
    }
}
