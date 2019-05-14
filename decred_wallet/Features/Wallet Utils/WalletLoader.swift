//
//  WalletLoader.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 09/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation

class WalletLoader: NSObject {
    var netType: String?
    var wallet: DcrlibwalletLibWallet?
    var syncer: Syncer?
    
    struct Static {
        static let instance: WalletLoader = WalletLoader()
    }
    
    public class var shared: WalletLoader {
        return Static.instance
    }
    
    public class var wallet: DcrlibwalletLibWallet? {
        return Static.instance.wallet
    }
    
    func initialize() -> NSError? {
        self.netType = Utils.infoForKey(GlobalConstants.Strings.NetType)
        
        var initWalletError: NSError?
        self.wallet = DcrlibwalletNewLibWallet(NSHomeDirectory() + "/Documents/dcrlibwallet/", "bdb", self.netType!, &initWalletError)
        self.syncer = Syncer()
        
        return initWalletError
    }
    
    var isWalletCreated: Bool {
        var walletExists: ObjCBool = ObjCBool(false)
        
        do {
            try self.wallet?.walletExists(&walletExists)
        } catch (let error) {
            print("Error checking if wallet exists: \(error.localizedDescription)")
        }
        
        return walletExists.boolValue
    }
}
