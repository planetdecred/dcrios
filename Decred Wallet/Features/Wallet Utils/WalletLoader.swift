//
//  WalletLoader.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

class WalletLoader: NSObject {
    static let appDataDir = NSHomeDirectory() + "/Documents/dcrlibwallet"
    
    var multiWallet: DcrlibwalletMultiWallet!
    var syncer: Syncer
    var notification: TransactionNotification
    
    var initialized = false
    var oneOrMoreWalletsExist = false
    
    var wallet: DcrlibwalletWallet? {
        return multiWallet.firstOrDefaultWallet()
    }
    
    var isSynced: Bool {
        return self.syncer.currentSyncOp == SyncOp.Done
    }
    
    override init() {
        syncer = Syncer()
        notification = TransactionNotification()
        super.init()
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
        if SpendingPinOrPassword.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PIN {
            privatePassphraseType = DcrlibwalletPassphraseTypePin
        }
        
        try AppDelegate.walletLoader.multiWallet.linkExistingWallet(WalletLoader.appDataDir,
                                                                    originalPubPass: startupPinOrPassword,
                                                                    privatePassphraseType: privatePassphraseType)
        
        DispatchQueue.main.async {
            NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
        }
    }
}
