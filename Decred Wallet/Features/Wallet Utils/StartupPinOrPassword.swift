//
//  StartupPinOrPassword.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

struct StartupPinOrPassword {
    static func requestNewSecurityCode(sender vc: UIViewController, callback: @escaping SecurityCodeRequestCallback) {
        // init secutity vc to use in getting new spending password or pin from user
        let securityVC = SecurityViewController.instantiate(from: .Security)
        securityVC.securityFor = LocalizedStrings.startup
        securityVC.initialSecurityType = self.currentSecurityType()
        securityVC.onSecurityCodeEntered = callback
        securityVC.modalPresentationStyle = .pageSheet
        vc.present(securityVC, animated: true, completion: nil)
    }
    
    static func clear(sender vc: UIViewController, done: (() -> Void)? = nil) {
        if !self.pinOrPasswordIsSet() {
            // nothing to clear
            done?()
            return
        }

        // pin/password was previously set, get the current pin/password before clearing
        Security.startup()
            .with(submitBtnText: LocalizedStrings.next)
            .requestSecurityCode(sender: vc) { currentCode, _, completion in
                self.changeWalletPublicPassphrase(currentCode: currentCode,
                                                  newCode: "",
                                                  type: nil,
                                                  completion: completion,
                                                  done: done)
        }
    }

    // alias for set function
    static func change(sender vc: UIViewController, done: (() -> Void)? = nil) {
        self.set(sender: vc, done: done)
    }
    
    static func set(sender vc: UIViewController, done: (() -> Void)? = nil) {
        if !self.pinOrPasswordIsSet() {
            // pin/password was not previously set
            self.requestNewSecurityCodeAndChangePassword(sender: vc, currentCode: "", done: done)
            return
        }

        // pin/password was previously set, get the current pin/password before proceeding
        Security.startup()
            .with(submitBtnText: LocalizedStrings.next)
            .requestSecurityCode(sender: vc) { currentCode, _, completion in
                completion?.securityCodeProcessed()
                self.requestNewSecurityCodeAndChangePassword(sender: vc, currentCode: currentCode, done: done)
        }
    }
    
    private static func requestNewSecurityCodeAndChangePassword(sender vc: UIViewController,
                                                                currentCode: String,
                                                                done: (() -> Void)? = nil) {
        
        self.requestNewSecurityCode(sender: vc) { newCode, type, completion in
            self.changeWalletPublicPassphrase(currentCode: currentCode,
                                              newCode: newCode,
                                              type: type,
                                              completion: completion,
                                              done: done)
        }
    }
    
    private static func changeWalletPublicPassphrase(currentCode: String,
                                                     newCode: String,
                                                     type securityType: SecurityType?,
                                                     completion: SecurityCodeRequestCompletionDelegate?,
                                                     done: (() -> Void)? = nil) {
        
        if securityType == nil && newCode != "" {
            completion?.securityCodeError(errorMessage: LocalizedStrings.securityTypeNotSpecified)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let passphraseType = securityType == .password ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
                
                try WalletLoader.shared.multiWallet.changeStartupPassphrase(currentCode.utf8Bits,
                                                                            newPassphrase: newCode.utf8Bits,
                                                                            passphraseType: passphraseType)
                
                DispatchQueue.main.async {
                    if newCode == "" {
                        Settings.setValue(false, for: Settings.Keys.IsStartupSecuritySet)
                        Settings.clearValue(for: Settings.Keys.StartupSecurityType)
                    } else {
                        Settings.setValue(true, for: Settings.Keys.IsStartupSecuritySet)
                        Settings.setValue(securityType!.rawValue, for: Settings.Keys.StartupSecurityType)
                    }
                    
                    completion?.securityCodeProcessed()
                    done?()
                }
            } catch let error {
                DispatchQueue.main.async {
                    var errorMessage = error.localizedDescription
                    if errorMessage == DcrlibwalletErrInvalidPassphrase {
                        // todo return to initial entry page
                        let securityType = StartupPinOrPassword.currentSecurityType()!.lowercased()
                        errorMessage = String(format: LocalizedStrings.incorrectSecurityInfo, securityType)
                    }
                    completion?.securityCodeError(errorMessage: errorMessage)
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
