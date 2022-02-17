//
//  SpendingPinOrPassword.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

enum SpendingPinOrPasswordType {
    case change
    case verify
}

struct SpendingPinOrPassword {
    static func begin(sender: UIViewController, walletID: Int, type: SpendingPinOrPasswordType, title: String, done: ((String) -> ())? = nil) {
        
        if LocalAuthentication.isWalletSetupBiometric(walletId: walletID) && type == .change {
            LocalAuthentication.localAuthenticaionWithWallet(walletId: walletID, completed: { result, error in
                if let currentCode = result {
                    let securityType = SpendingPinOrPassword.securityType(for: walletID)
                    self.verifyWalletSpendingPassphrase(walletID: walletID,
                                                        currentCode: currentCode,
                                                        currentCodeRequestDelegate: nil,
                                                        securityType: securityType,
                                                        sender: sender,
                                                        type: type,
                                                        done: done)
                } else {
                    self.confirmPinPass(sender: sender, walletID: walletID, type: type, title: title, done: done)
                }
            })
        } else {
            self.confirmPinPass(sender: sender, walletID: walletID, type: type, title: title, done: done)
        }
    }
    
    private static func confirmPinPass(sender: UIViewController, walletID: Int, type: SpendingPinOrPasswordType, title: String, done: ((String) -> ())? = nil) {
        Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: walletID))
            .with(prompt: title)
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestCurrentCode(sender: sender) {
                currentCode, securityType, currentCodeRequestDelegate in
                self.verifyWalletSpendingPassphrase(walletID: walletID,
                                                    currentCode: currentCode,
                                                    currentCodeRequestDelegate: currentCodeRequestDelegate,
                                                    securityType: securityType,
                                                    sender: sender,
                                                    type: type,
                                                    done: done)
        }
    }
    
    private static func verifyWalletSpendingPassphrase(walletID: Int,
                                                       currentCode: String,
                                                       currentCodeRequestDelegate: InputDialogDelegate?,
                                                       securityType: SecurityType,
                                                       sender: UIViewController,
                                                       type: SpendingPinOrPasswordType,
                                                       done: ((String) -> ())?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let wallet = WalletLoader.shared.multiWallet.wallet(withID: walletID)
                try wallet?.unlock(currentCode.utf8Bits)
                wallet?.lock()
                DispatchQueue.main.async {
                    currentCodeRequestDelegate?.dismissDialog()
                    if type == .change {
                        self.change(sender: sender, walletID: walletID, currentCode: currentCode, done: done)
                    } else {
                        done?(currentCode)
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        currentCodeRequestDelegate?.displayPassphraseError(errorMessage: self.invalidSecurityCodeMessage(for: walletID))
                    }
                }
            }
        }
    }
    
    private static func change(sender: UIViewController, walletID: Int, currentCode: String, done: ((String) -> ())? = nil) {
        Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: walletID))
            .with(prompt: LocalizedStrings.confirmToChange)
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestNewCode(sender: sender, isChangeAttempt: true) {
                newCode, securityType, newCodeRequestDelegate in
                
                self.changeWalletSpendingPassphrase(walletID: walletID,
                                                    currentCode: currentCode,
                                                    newCode: newCode,
                                                    newCodeRequestDelegate: newCodeRequestDelegate,
                                                    newCodeType: securityType,
                                                    done: done)
        }
    }
    
    private static func changeWalletSpendingPassphrase(walletID: Int,
                                                       currentCode: String,
                                                       newCode: String,
                                                       newCodeRequestDelegate: InputDialogDelegate?,
                                                       newCodeType: SecurityType,
                                                       done: ((String) -> ())?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.changePrivatePassphrase(forWallet: walletID,
                                                                            oldPrivatePassphrase: currentCode.utf8Bits,
                                                                            newPrivatePassphrase: newCode.utf8Bits,
                                                                            privatePassphraseType: newCodeType.type)
                
                DispatchQueue.main.async {
                    newCodeRequestDelegate?.dismissDialog()
                    done?(newCode)
                }
            } catch let error {
                DispatchQueue.main.async {
                    newCodeRequestDelegate?.displayError(errorMessage: error.localizedDescription)
                }
            }
        }
    }
    
    static func securityType(for walletID: Int) -> SecurityType {
        if let wallet = WalletLoader.shared.multiWallet.wallet(withID: walletID) {
            return SpendingPinOrPassword.securityType(for: wallet)
        }
        return .password
    }
    
    static func securityType(for wallet: DcrlibwalletWallet) -> SecurityType {
        return wallet.privatePassphraseType == DcrlibwalletPassphraseTypePin ? .pin : .password
    }
    
    static func invalidSecurityCodeMessage(for walletID: Int) -> String {
        let securityType = self.securityType(for: walletID) == .pin ? LocalizedStrings.pin : LocalizedStrings.password.lowercased()
        return String(format: LocalizedStrings.wrongSecurityCode, LocalizedStrings.spending.lowercased(), securityType)
    }
    
    static func invalidSecurityCodeMessage(for wallet: DcrlibwalletWallet) -> String {
        let securityType = self.securityType(for: wallet) == .pin ? LocalizedStrings.pin : LocalizedStrings.password.lowercased()
        return String(format: LocalizedStrings.wrongSecurityCode, LocalizedStrings.spending.lowercased(), securityType)
    }
}
