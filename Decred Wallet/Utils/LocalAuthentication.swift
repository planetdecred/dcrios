//
//  WalletAuthentication.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
//

import Foundation
import LocalAuthentication
import SwiftKeychainWrapper

class LocalAuthentication {
    
    private static func getPinOrPassWallet(walletId: Int) -> (String?) {
        let key = String(format: GlobalConstants.Strings.BIOMATRIC_AUTHEN, walletId)
        guard let passOrPin = KeychainWrapper.standard.string(forKey: key) else { return nil }
        return passOrPin
    }
    
    static func setWalletPassword(walletId: Int, password: String) {
        let key = String(format: GlobalConstants.Strings.BIOMATRIC_AUTHEN, walletId)
        KeychainWrapper.standard.set(password, forKey: key)
    }
    
    static func removeWalletPassword(walletId: Int) {
        let key = String(format: GlobalConstants.Strings.BIOMATRIC_AUTHEN, walletId)
        KeychainWrapper.standard.removeObject(forKey: key)
    }
    
    static func isWalletSetupBiometric(walletId: Int) -> Bool {
        return self.getPinOrPassWallet(walletId: walletId) != nil
    }
    
    static func isBiometricSupported() -> (String?, NSError?) {
        let localAuthenticationContext = LAContext()
        var authError: NSError?
        var resultText: String?
        if localAuthenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            if #available(iOS 11.0, *) {
                switch localAuthenticationContext.biometryType {
                case .faceID:
                    resultText = LocalizedStrings.useFaceID
                    break

                case .touchID:
                    resultText = LocalizedStrings.useTouchId
                    break

                default:
                    break
                }
            } else {
                authError = NSError(domain: "dcr.ios.wallet", code: 2, userInfo: [NSLocalizedDescriptionKey: "This device does not supported"])
            }
        } else {
            authError = NSError(domain: "dcr.ios.wallet", code: 2, userInfo: [NSLocalizedDescriptionKey: "This device does not supported"])
        }
        return (resultText, authError)
    }
    
    static func localAuthenticaionWithWallet(walletId: Int, completed: @escaping (String?, Error?) -> ()) {
        let (rs, error) = self.isBiometricSupported()
        guard let reason = rs else {
            completed(nil, error)
            return
        }
        let password = self.getPinOrPassWallet(walletId: walletId)
//        if password == nil {
//            completed(nil, NSError(domain: "dcr.ios.wallet", code: 2, userInfo: [NSLocalizedDescriptionKey: "bimetric is not setup"]))
//            return
//        }
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
            DispatchQueue.main.async {
                if success {
                    completed(password, nil)
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    completed(nil ,error)
                }
            }
        }
    }
}
