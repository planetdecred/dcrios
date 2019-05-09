//
//  WalletLoader.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 09/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation

struct WalletLoader {
    static var isWalletCreated: Bool {
        // todo master has
        // return SingleInstance.shared.wallet?.walletExists()
    
        let netType = infoForKey(GlobalConstants.Strings.NetType)!
        let fm = FileManager()
        let result = fm.fileExists(atPath: NSHomeDirectory()+"/Documents/dcrlibwallet/\(netType)/wallet.db")
        return result
    }
    
    static func initialize() -> NSError? {
        let netType = infoForKey(GlobalConstants.Strings.NetType)!
        
        var initWalletError: NSError?
        SingleInstance.shared.wallet = DcrlibwalletNewLibWallet(NSHomeDirectory() + "/Documents/dcrlibwallet/", "bdb", netType, &initWalletError)
        SingleInstance.shared.wallet?.initLoader()
        
        return initWalletError
    }
}
