//
//  DcrdWalletCreationSupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation

protocol DcrdCreateRestoreWalletProtocol: DcrdBaseProtocol {
    func createWallet(seed:String, passwd:String) throws
    func openWallet() -> Bool
}

extension DcrdCreateRestoreWalletProtocol{
    func createWallet(seed:String, passwd:String) throws {
        try wallet?.createWallet(passwd, seedMnemonic: seed)
    }
    
    func openWallet() -> Bool{
        var result = false
        do{
            result = ((try wallet?.open()) != nil)
        } catch let error{
            print(error)
        }
        return result
    }
}
