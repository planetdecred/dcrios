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
        var walletExists: ObjCBool = ObjCBool(false)
        
        do {
            try SingleInstance.shared.wallet?.walletExists(&walletExists)
        } catch (let error) {
            print("Error checking if wallet exists: \(error.localizedDescription)")
        }
        
        return walletExists.boolValue
    }
    
    static func initialize() -> NSError? {
        let netType = Utils.infoForKey(GlobalConstants.Strings.NetType)!
        
        var initWalletError: NSError?
        SingleInstance.shared.wallet = DcrlibwalletNewLibWallet(NSHomeDirectory() + "/Documents/dcrlibwallet/", "bdb", netType, &initWalletError)
        
        return initWalletError
    }
}
