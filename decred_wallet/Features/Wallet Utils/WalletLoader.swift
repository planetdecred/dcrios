//
//  WalletLoader.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 09/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation

class WalletLoader: NSObject {
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
        let netType = Utils.infoForKey(GlobalConstants.Strings.NetType)
        
        var initWalletError: NSError?
        self.wallet = DcrlibwalletNewLibWallet(NSHomeDirectory() + "/Documents/dcrlibwallet/", "bdb", netType!, &initWalletError)
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

extension DcrlibwalletLibWallet {
    func totalWalletBalance() throws -> Double {
        var getAccountsError: NSError?
        let accountsJson = WalletLoader.wallet?.getAccounts(0, error: &getAccountsError)
        if getAccountsError != nil {
            throw getAccountsError!
        }
        
        let accounts = try JSONDecoder().decode(WalletAccounts.self, from: accountsJson!.utf8Bits)
        return accounts.Acc.filter({ !$0.isHidden }).map({ $0.dcrTotalBalance }).reduce(0,+)
    }
}
