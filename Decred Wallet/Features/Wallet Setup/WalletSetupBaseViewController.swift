//
//  WalletSetupBaseController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

// todo remove this base view controller
//class WalletSetupBaseViewController: UIViewController {
//    static func instantiate() -> Self {
//        return Storyboard.WalletSetup.instantiateViewController(for: self)
//    }
//
//    func finalizeWalletSetup(_ seed: String, _ pinOrPassword: String, _ securityType: String, _ completionDelegate: SecurityRequestCompletionDelegate?) {
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let this = self else { return }
//
//            let multiwallet = WalletLoader.shared.multiWallet
//            let privatePassphraseType = securityType == SecurityType.password.rawValue ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
//
//            do {
//                try multiwallet?.createNewWallet(pinOrPassword, privatePassphraseType: privatePassphraseType)
//
//                DispatchQueue.main.async {
//                    Settings.setValue(securityType, for: Settings.Keys.SpendingPassphraseSecurityType)
//
//                    if Settings.newWalletSetUp {
//                        Settings.setValue(seed, for: Settings.Keys.Seed)
//                        Settings.setValue(false, for: Settings.Keys.SeedBackedUp)
//                        NavigationMenuTabBarController.setupMenuAndLaunchApp()
//                    } else {
//                        Settings.setValue(true, for: Settings.Keys.SeedBackedUp)
//                        completionDelegate?.securityCodeProcessed(true, nil)
//                        this.performSegue(withIdentifier: "recoverySuccess", sender: self)
//                    }
//                }
//            } catch let error {
//                DispatchQueue.main.async {
//                    completionDelegate?.securityCodeProcessed(false, error.localizedDescription)
//                }
//            }
//        }
//    }
//}
