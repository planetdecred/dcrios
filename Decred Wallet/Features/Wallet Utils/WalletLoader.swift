//
//  WalletLoader.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet
import Signals

class WalletLoader: NSObject {
    static let shared = WalletLoader()
    static let appDataDir = NSHomeDirectory() + "/Documents/dcrlibwallet"
    
    var multiWallet: DcrlibwalletMultiWallet!
    
    var initialized = false
    var oneOrMoreWalletsExist = false
    
    var walletSeedBackedUp: Signal = Signal<Int>()
    
    var wallet: DcrlibwalletWallet? {
        return multiWallet.firstOrDefaultWallet()
    }
    
    func initMultiWallet() -> NSError? {
        var error: NSError?
        self.multiWallet = DcrlibwalletNewMultiWallet(WalletLoader.appDataDir, "bdb", BuildConfig.NetType, &error)
        
        if error == nil {
            self.initialized = true
            self.oneOrMoreWalletsExist = self.multiWallet.loadedWalletsCount() > 0
        }
        
        return error
    }
    
    func linkExistingWalletAndStartApp(startupPinOrPassword: String) throws {
        var privatePassphraseType = DcrlibwalletPassphraseTypePass
        if SpendingPinOrPassword.currentSecurityType() == SecurityType.pin.rawValue {
            privatePassphraseType = DcrlibwalletPassphraseTypePin
        }
        
        try self.multiWallet.linkExistingWallet(WalletLoader.appDataDir,
                                                originalPubPass: startupPinOrPassword,
                                                privatePassphraseType: privatePassphraseType)
        
        DispatchQueue.main.async {
            NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
        }
    }
    
    func createWallet(spendingPinOrPassword: String, securityType: SecurityType, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let privatePassphraseType = securityType == .password ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
            
            do {
                try self.multiWallet.createNewWallet(spendingPinOrPassword, privatePassphraseType: privatePassphraseType)
                
                DispatchQueue.main.async {
                    Settings.setValue(securityType.rawValue, for: Settings.Keys.SpendingPassphraseSecurityType)
                    completion(nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func restoreWallet(seed: String, spendingPinOrPassword: String, securityType: SecurityType, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let privatePassphraseType = securityType == .password ? DcrlibwalletPassphraseTypePass : DcrlibwalletPassphraseTypePin
            
            do {
                try self.multiWallet.restore(seed,
                                             privatePassphrase: spendingPinOrPassword,
                                             privatePassphraseType: privatePassphraseType)
                
                DispatchQueue.main.async {
                    Settings.setValue(securityType.rawValue, for: Settings.Keys.SpendingPassphraseSecurityType)
                    completion(nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
}
