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
    func signTransaction(transaction: WalletConstructTxResponse) -> Data?
    func publish(transaction:Data)
}

extension DcrSendTransactionProtocol{
    func prepareTransaction(from account:Int32, to address:String, amount:Int64, shouldBeConfirmed:Bool){
        wallet?.constructTransaction(address, amount: amount, srcAccount: account, requiredConfirmations: shouldBeConfirmed)
    }
    func signTransaction(transaction: WalletConstructTxResponse) -> Data?{
        return nil
    }
    func publish(transaction:Data){
        
    }
}


