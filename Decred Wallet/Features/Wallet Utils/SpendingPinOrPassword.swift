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
    static func change(sender: UIViewController) {
        Security.spending()
            .with(submitBtnText: LocalizedStrings.next).requestCurrentAndNewCode(sender: sender) {
                currentCode, currentCodeRequestCompletion, newCode, newCodeRequestCompletion, newCodeType in
                
                self.changeWalletSpendingPassphrase(currentCode: currentCode,
                                                    currentCodeRequestCompletion: currentCodeRequestCompletion,
                                                    newCode: newCode,
                                                    newCodeRequestCompletion: newCodeRequestCompletion,
                                                    newCodeType: newCodeType)
        }
    }
    
    private static func changeWalletSpendingPassphrase(currentCode: String,
                                                       currentCodeRequestCompletion: SecurityCodeRequestCompletionDelegate?,
                                                       newCode: String,
                                                       newCodeRequestCompletion: SecurityCodeRequestCompletionDelegate?,
                                                       newCodeType: SecurityType) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let passphraseType = newCodeType == .password ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
                
                try WalletLoader.shared.multiWallet.changePrivatePassphrase(forWallet: WalletLoader.shared.firstWallet!.id_,
                                                                            oldPrivatePassphrase: currentCode.utf8Bits,
                                                                            newPrivatePassphrase: newCode.utf8Bits,
                                                                            privatePassphraseType: passphraseType)
                
                DispatchQueue.main.async {
                    newCodeRequestCompletion?.securityCodeProcessed()
                    currentCodeRequestCompletion?.securityCodeProcessed()
                    Settings.setValue(newCodeType.rawValue, for: Settings.Keys.SpendingPassphraseSecurityType)
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
    
    static func currentSecurityType() -> SecurityType {
        if Settings.readOptionalValue(for: Settings.Keys.SpendingPassphraseSecurityType) == SecurityType.pin.rawValue {
            return .pin
        }
        return .password
    }
    
    static func invalidSecurityCodeMessage() -> String {
        let securityType = self.currentSecurityType() == .pin ? LocalizedStrings.pin : LocalizedStrings.password.lowercased()
        return String(format: LocalizedStrings.wrongSecurityCode, LocalizedStrings.spending.lowercased(), securityType)
    }
}
