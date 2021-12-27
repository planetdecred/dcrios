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

class WalletAuthentication {
    static func getPinOrPassWallet(walletId: Int) -> (String?) {
        let key = String(format: GlobalConstants.Strings.BIOMATRIC_AUTHEN, walletId)
        guard let passOrPin = KeychainWrapper.standard.string(forKey: key) else { return nil }
        
        return passOrPin
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
                authError = NSError(domain: "This device does not supported", code: 2, userInfo: nil)
            }
        } else {
            authError = NSError(domain: "This device does not supported", code: 2, userInfo: nil)
        }
        return (resultText, authError)
    }
    
    static func localAuthenticaion(reason: String, completed: @escaping (Error?) -> ()) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
            DispatchQueue.main.async {
                if success {
                    completed(nil)
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    completed(error)
                }
            }
        }
    }
}
