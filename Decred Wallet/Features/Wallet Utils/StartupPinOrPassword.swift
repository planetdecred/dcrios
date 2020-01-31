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
    static func set(sender: UIViewController, done: (() -> Void)? = nil) {
        if self.pinOrPasswordIsSet() {
            self.change(sender: sender, done: done)
            return
        }
        
        Security.startup().requestNewCode(sender: sender) { code, type, completion in
            
            self.changeWalletPublicPassphrase(currentCode: "",
                                              currentCodeRequestCompletion: nil,
                                              newCode: code,
                                              newCodeRequestCompletion: completion,
                                              newCodeType: type,
                                              done: done)
        }
    }
    
    static func change(sender: UIViewController, done: (() -> Void)? = nil) {
        if !self.pinOrPasswordIsSet() {
            self.set(sender: sender, done: done)
            return
        }
        
        Security.startup()
            .with(submitBtnText: LocalizedStrings.next)
            .requestCurrentAndNewCode(sender: sender) {
                currentCode, currentCodeRequestCompletion, newCode, newCodeRequestCompletion, newCodeType in
                
                self.changeWalletPublicPassphrase(currentCode: currentCode,
                                                  currentCodeRequestCompletion: currentCodeRequestCompletion,
                                                  newCode: newCode,
                                                  newCodeRequestCompletion: newCodeRequestCompletion,
                                                  newCodeType: newCodeType,
                                                  done: done)
        }
    }
    
    static func clear(sender vc: UIViewController, done: (() -> Void)? = nil) {
        if !self.pinOrPasswordIsSet() {
            // nothing to clear
            done?()
            return
        }

        Security.startup()
            .with(submitBtnText: LocalizedStrings.next)
            .requestCurrentCode(sender: vc) { currentCode, _, completion in
                
                self.changeWalletPublicPassphrase(currentCode: currentCode,
                                                  currentCodeRequestCompletion: completion,
                                                  newCode: "",
                                                  newCodeRequestCompletion: nil,
                                                  newCodeType: nil,
                                                  done: done)
        }
    }

    private static func changeWalletPublicPassphrase(currentCode: String,
                                                     currentCodeRequestCompletion: SecurityCodeRequestCompletionDelegate?,
                                                     newCode: String,
                                                     newCodeRequestCompletion: SecurityCodeRequestCompletionDelegate?,
                                                     newCodeType: SecurityType?,
                                                     done: (() -> Void)?) {
        
        if newCodeType == nil && newCode != "" {
            newCodeRequestCompletion?.securityCodeError(errorMessage: LocalizedStrings.securityTypeNotSpecified)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let passphraseType = newCodeType == .password ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
                
                try WalletLoader.shared.multiWallet.changeStartupPassphrase(currentCode.utf8Bits,
                                                                            newPassphrase: newCode.utf8Bits,
                                                                            passphraseType: passphraseType)

                DispatchQueue.main.async {
                    newCodeRequestCompletion?.securityCodeProcessed()
                    currentCodeRequestCompletion?.securityCodeProcessed()
                    done?()
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        newCodeRequestCompletion?.securityCodeProcessed()
                        currentCodeRequestCompletion?.securityCodeError(errorMessage: self.invalidSecurityCodeMessage())
                    } else {
                        newCodeRequestCompletion?.securityCodeError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func pinOrPasswordIsSet() -> Bool {
        return WalletLoader.shared.multiWallet.isStartupSecuritySet()
    }

    static func currentSecurityType() -> SecurityType {
        if WalletLoader.shared.multiWallet.startupSecurityType() == DcrlibwalletPassphraseTypePin {
            return .pin
        }
        return .password
    }
    
    static func invalidSecurityCodeMessage() -> String {
        let securityType = self.currentSecurityType() == .pin ? LocalizedStrings.pin : LocalizedStrings.password.lowercased()
        return String(format: LocalizedStrings.wrongSecurityCode, LocalizedStrings.startup.lowercased(), securityType)
    }
}
