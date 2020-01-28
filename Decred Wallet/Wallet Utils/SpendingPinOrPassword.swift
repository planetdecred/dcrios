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
                currentCode, currentCodeRequestDelegate, newCode, newCodeRequestDelegate, newCodeType in
                
                self.changeWalletSpendingPassphrase(currentCode: currentCode,
                                                    currentCodeRequestDelegate: currentCodeRequestDelegate,
                                                    newCode: newCode,
                                                    newCodeRequestDelegate: newCodeRequestDelegate,
                                                    newCodeType: newCodeType)
        }
    }
    
    private static func changeWalletSpendingPassphrase(currentCode: String,
                                                       currentCodeRequestDelegate: InputDialogDelegate?,
                                                       newCode: String,
                                                       newCodeRequestDelegate: InputDialogDelegate?,
                                                       newCodeType: SecurityType) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let passphraseType = newCodeType == .password ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
                
                try WalletLoader.shared.multiWallet.changePrivatePassphrase(forWallet: WalletLoader.shared.firstWallet!.id_,
                                                                            oldPrivatePassphrase: currentCode.utf8Bits,
                                                                            newPrivatePassphrase: newCode.utf8Bits,
                                                                            privatePassphraseType: passphraseType)
                
                DispatchQueue.main.async {
                    newCodeRequestDelegate?.dismissDialog()
                    currentCodeRequestDelegate?.dismissDialog()
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        newCodeRequestDelegate?.dismissDialog()
                        currentCodeRequestDelegate?.displayError(errorMessage: self.invalidSecurityCodeMessage())
                    } else {
                        newCodeRequestDelegate?.displayError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    // todo remove eventually, different wallets have different spending security code type
    static func currentSecurityType() -> SecurityType {
        if WalletLoader.shared.firstWallet?.privatePassphraseType == DcrlibwalletPassphraseTypePin {
            return .pin
        }
        return .password
    }
    
    static func securityType(for wallet: DcrlibwalletWallet) -> SecurityType {
        return wallet.privatePassphraseType == DcrlibwalletPassphraseTypePin ? .pin : .password
    }
    
    // todo remove eventually, different wallets have different spending security code type
    static func invalidSecurityCodeMessage() -> String {
        let securityType = self.currentSecurityType() == .pin ? LocalizedStrings.pin : LocalizedStrings.password.lowercased()
        return String(format: LocalizedStrings.wrongSecurityCode, LocalizedStrings.spending.lowercased(), securityType)
    }
    
    static func invalidSecurityCodeMessage(for wallet: DcrlibwalletWallet) -> String {
        let securityType = self.securityType(for: wallet) == .pin ? LocalizedStrings.pin : LocalizedStrings.password.lowercased()
        return String(format: LocalizedStrings.wrongSecurityCode, LocalizedStrings.spending.lowercased(), securityType)
    }
}
