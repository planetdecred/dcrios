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
    func prepareTransaction(from account:Int32, to address:String, amount:Int64, shouldBeConfirmed:Bool)
    func signTransaction(transaction: WalletConstructTxResponse, password:Data) -> Data?
    func publish(transaction:Data)  -> Data?
}

extension DcrSendTransactionProtocol{
    func prepareTransaction(from account:Int32, to address:String, amount:Int64, shouldBeConfirmed:Bool) throws {
        try wallet?.constructTransaction(address, amount: amount, srcAccount: account, requiredConfirmations:Int32(NSNumber(booleanLiteral: shouldBeConfirmed)))
    }
    func signTransaction(transaction: WalletConstructTxResponse, password:Data) throws -> Data?  {
        return try wallet?.signTransaction(transaction.unsignedTransaction(), privPass: password)
    }
    func publish(transaction:Data) throws -> Data?{
        return try wallet?.publishTransaction(transaction)
    }
}


