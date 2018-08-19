//
//  DcrTransactionTraffic.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Mobilewallet

protocol DcrSendTransactionProtocol: DcrdBaseProtocol{
    func prepareTransaction(from account:Int32, to address:String, amount:Double, isSendAll: Bool?) throws -> MobilewalletConstructTxResponse?
    func signTransaction(transaction: MobilewalletConstructTxResponse, password:Data) throws -> Data?
    func publish(transaction:Data) throws -> Data?
}

extension DcrSendTransactionProtocol{
    
    func prepareTransaction(from account:Int32, to address:String, amount:Double, isSendAll: Bool?) throws -> MobilewalletConstructTxResponse? {
        let isShouldBeConfirmed = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
        
        return try AppContext.instance.decrdConnection?.wallet?.constructTransaction(address, amount: Int64(amount), srcAccount: account, requiredConfirmations:Int32(isShouldBeConfirmed ? 0 : 2), sendAll: isSendAll ?? false)
    }
    func signTransaction(transaction: MobilewalletConstructTxResponse, password:Data) throws -> Data?  {
        return try AppContext.instance.decrdConnection?.wallet?.signTransaction(transaction.unsignedTransaction(), privPass: password)
    }
    func publish(transaction:Data) throws -> Data?{
        return try AppContext.instance.decrdConnection?.wallet?.publishTransaction(transaction)
    }
}

