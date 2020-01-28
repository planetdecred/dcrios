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
    static func requestNewSecurityCode(sender vc: UIViewController, callback: @escaping SecurityCodeRequestCallback) {
        // init secutity vc to use in getting new spending password or pin from user
        let securityVC = SecurityViewController.instantiate(from: .Security)
        securityVC.securityFor = .Spending
        securityVC.initialSecurityType = self.currentSecurityType()
        securityVC.onSecurityCodeEntered = callback
        securityVC.modalPresentationStyle = .pageSheet
        vc.present(securityVC, animated: true, completion: nil)
    }
    
    static func change(sender vc: UIViewController) {
        Security.spending()
            .with(submitBtnText: LocalizedStrings.next)
            .requestSecurityCode(sender: vc) { currentCode, _, completion in
                completion?.securityCodeProcessed()
                self.requestNewSecurityCodeAndChangePassword(sender: vc, currentCode: currentCode)
        }
    }
    
    private static func requestNewSecurityCodeAndChangePassword(sender vc: UIViewController, currentCode: String) {
        self.requestNewSecurityCode(sender: vc) { newCode, type, completion in
            self.changeWalletSpendingPassphrase(currentCode: currentCode, newCode: newCode, type: type, completion: completion)
        }
    }
    
    private static func changeWalletSpendingPassphrase(currentCode: String,
                                                       newCode: String,
                                                       type securityType: SecurityType,
                                                       completion: SecurityCodeRequestCompletionDelegate?) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let passphraseType = securityType == .password ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
                
                try WalletLoader.shared.multiWallet.changePrivatePassphrase(forWallet: WalletLoader.shared.wallet!.id_,
                                                                            oldPrivatePassphrase: currentCode.utf8Bits,
                                                                            newPrivatePassphrase: newCode.utf8Bits,
                                                                            privatePassphraseType: passphraseType)
                
                DispatchQueue.main.async {
                    completion?.securityCodeProcessed()
                    Settings.setValue(securityType.rawValue, for: Settings.Keys.SpendingPassphraseSecurityType)
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        // todo return to initial entry page to display this error
                        completion?.securityCodeError(errorMessage: self.invalidSecurityCodeMessage())
                    } else {
                        completion?.securityCodeError(errorMessage: error.localizedDescription)
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
