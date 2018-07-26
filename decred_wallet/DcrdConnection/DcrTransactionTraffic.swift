//
//  DcrTransactionTraffic.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Wallet

protocol DcrSendTransactionProtocol: DcrdBaseProtocol{
    func prepareTransaction(from account:Int32, to address:String, amount:Double, isSendAll: Bool?) throws -> WalletConstructTxResponse?
    func signTransaction(transaction: WalletConstructTxResponse, password:Data) throws -> Data?
    func publish(transaction:Data) throws -> Data?
}

extension DcrSendTransactionProtocol{
    
    func prepareTransaction(from account:Int32, to address:String, amount:Double, isSendAll: Bool?) throws -> WalletConstructTxResponse? {
        let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
        
        return try wallet?.constructTransaction(address, amount: Int64(amount), srcAccount: account, requiredConfirmations:Int32(isShouldBeConfirmed ? 0 : 2), sendAll: isSendAll ?? false)
    }
    func signTransaction(transaction: WalletConstructTxResponse, password:Data) throws -> Data?  {
        return try wallet?.signTransaction(transaction.unsignedTransaction(), privPass: password)
    }
    func publish(transaction:Data) throws -> Data?{
        return try wallet?.publishTransaction(transaction)
    }
}

