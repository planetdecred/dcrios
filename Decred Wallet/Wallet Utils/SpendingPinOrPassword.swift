//
//  SpendingPinOrPassword.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

struct SpendingPinOrPassword {
    static func change(sender: UIViewController, walletID: Int, done: (() -> ())? = nil) {
        Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: walletID))
            .with(prompt: LocalizedStrings.confirmToChange)
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestCurrentAndNewCode(sender: sender) {
                currentCode, currentCodeRequestDelegate, newCode, newCodeRequestDelegate, newCodeType in
                
                self.changeWalletSpendingPassphrase(walletID: walletID,
                                                    currentCode: currentCode,
                                                    currentCodeRequestDelegate: currentCodeRequestDelegate,
                                                    newCode: newCode,
                                                    newCodeRequestDelegate: newCodeRequestDelegate,
                                                    newCodeType: newCodeType,
                                                    done: done)
        }
    }
    
    private static func changeWalletSpendingPassphrase(walletID: Int,
                                                       currentCode: String,
                                                       currentCodeRequestDelegate: InputDialogDelegate?,
                                                       newCode: String,
                                                       newCodeRequestDelegate: InputDialogDelegate?,
                                                       newCodeType: SecurityType,
                                                       done: (() -> ())?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.changePrivatePassphrase(forWallet: walletID,
                                                                            oldPrivatePassphrase: currentCode.utf8Bits,
                                                                            newPrivatePassphrase: newCode.utf8Bits,
                                                                            privatePassphraseType: newCodeType.type)
                
                DispatchQueue.main.async {
                    newCodeRequestDelegate?.dismissDialog()
                    currentCodeRequestDelegate?.dismissDialog()
                    done?()
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        newCodeRequestDelegate?.dismissDialog()
                        currentCodeRequestDelegate?.displayError(errorMessage: self.invalidSecurityCodeMessage(for: walletID))
                    } else {
                        newCodeRequestDelegate?.displayError(errorMessage: error.localizedDescription)
                    }
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
