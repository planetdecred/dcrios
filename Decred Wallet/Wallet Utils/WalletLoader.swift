//
//  WalletLoader.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

class WalletLoader: NSObject {
    static let shared = WalletLoader()
    static let appDataDir = NSHomeDirectory() + "/Documents/dcrlibwallet"
    
    var multiWallet: DcrlibwalletMultiWallet!
    
    var isInitialized: Bool {
        return self.multiWallet != nil
    }
    
    var oneOrMoreWalletsExist: Bool {
        return self.multiWallet.loadedWalletsCount() > 0
    }
    
    var wallets: [DcrlibwalletWallet] {
        var wallets = [DcrlibwalletWallet]()
        
        let walletsIterator = WalletLoader.shared.multiWallet.walletsIterator()
        while let wallet = walletsIterator?.next() {
            wallets.append(wallet)
        }
        
        // sort by id, as dcrlibwallet may return wallets in any order
        wallets.sort(by: { $0.id_ < $1.id_ })
        
        return wallets
    }
    
    
    var firstWallet: DcrlibwalletWallet? {
        return self.wallets.first
    }
    
    func initMultiWallet() -> NSError? {
        var error: NSError?
        self.multiWallet = DcrlibwalletNewMultiWallet(WalletLoader.appDataDir, "bdb", BuildConfig.NetType, &error)
        return error
    }
    
    func createWallet(spendingPinOrPassword: String, securityType: SecurityType, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.multiWallet.createNewWallet(spendingPinOrPassword, privatePassphraseType: securityType.type)
                
                DispatchQueue.main.async {
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
            do {
                try self.multiWallet.restore(seed,
                                             privatePassphrase: spendingPinOrPassword,
                                             privatePassphraseType: securityType.type)
                
                DispatchQueue.main.async {
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
