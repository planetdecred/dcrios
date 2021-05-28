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
        
        Security.startup().requestNewCode(sender: sender, isChangeAttempt: false) { code, type, newCodeRequestDelegate in
            
            self.changeWalletPublicPassphrase(currentCode: "",
                                              currentCodeRequestDelegate: nil,
                                              newCode: code,
                                              newCodeRequestDelegate: newCodeRequestDelegate,
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
            .with(prompt: LocalizedStrings.confirmToChange)
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestCurrentCode(sender: sender) {
                currentCode, securityType, currentCodeRequestDelegate in
                
                self.verifyWalletPublicPassphrase(currentCode: currentCode,
                                                  currentCodeRequestDelegate: currentCodeRequestDelegate,
                                                  securityType: securityType,
                                                  sender: sender,
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
            .with(prompt: LocalizedStrings.confirmToRemove)
            .with(submitBtnText: LocalizedStrings.remove)
            .requestCurrentCode(sender: vc) { currentCode, _, dialogDelegate in
                
                self.changeWalletPublicPassphrase(currentCode: currentCode,
                                                  currentCodeRequestDelegate: dialogDelegate,
                                                  newCode: "",
                                                  newCodeRequestDelegate: nil,
                                                  newCodeType: .password,
                                                  done: done)
                if Settings.readBoolValue(for: DcrlibwalletUseBiometricConfigKey) {
                   KeychainWrapper.standard.removeObject(forKey: "StartupPinOrPassword")
                    Settings.clearValue(for: DcrlibwalletUseBiometricConfigKey)
                }
        }
    }
    
    private static func verifyWalletPublicPassphrase(currentCode: String,
                                                       currentCodeRequestDelegate: InputDialogDelegate?,
                                                       securityType: SecurityType,
                                                       sender: UIViewController,
                                                       done: (() -> ())?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.verifyStartupPassphrase(currentCode.utf8Bits)
                DispatchQueue.main.async {
                    currentCodeRequestDelegate?.dismissDialog()
                    Security.startup().requestNewCode(sender: sender, isChangeAttempt: false) { code, type, newCodeRequestDelegate in
                        
                        self.changeWalletPublicPassphrase(currentCode: currentCode,
                                                          currentCodeRequestDelegate: nil,
                                                          newCode: code,
                                                          newCodeRequestDelegate: newCodeRequestDelegate,
                                                          newCodeType: type,
                                                          done: done)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        currentCodeRequestDelegate?.displayPassphraseError(errorMessage: self.invalidSecurityCodeMessage())
                    }
                }
            }
        }
    }

    private static func changeWalletPublicPassphrase(currentCode: String,
                                                     currentCodeRequestDelegate: InputDialogDelegate?,
                                                     newCode: String,
                                                     newCodeRequestDelegate: InputDialogDelegate?,
                                                     newCodeType: SecurityType,
                                                     done: (() -> Void)?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.changeStartupPassphrase(currentCode.utf8Bits,
                                                                            newPassphrase: newCode.utf8Bits,
                                                                            passphraseType: newCodeType.type)

                DispatchQueue.main.async {
                    newCodeRequestDelegate?.dismissDialog()
                    currentCodeRequestDelegate?.dismissDialog()
                    if Settings.readBoolValue(for: DcrlibwalletUseBiometricConfigKey) {
                       KeychainWrapper.standard.set(newCode, forKey: "StartupPinOrPassword")
                    }
                    done?()
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        newCodeRequestDelegate?.dismissDialog()
                        currentCodeRequestDelegate?.displayPassphraseError(errorMessage: self.invalidSecurityCodeMessage())
                    } else {
                        newCodeRequestDelegate?.displayError(errorMessage: error.localizedDescription)
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
