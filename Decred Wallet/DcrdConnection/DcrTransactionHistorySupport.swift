//
//  DcrTransactionHistorySupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Wallet

struct JsonTransaction : Decodable{
    
}

typealias GetTransactionsResponseCallback = ((JsonTransaction)->Void)
typealias GetTransactionsResponseFailureCallback = ((Error)->Void)

protocol WalletGetTransactionsResponseListenerProtocol {
    func onResult(json:String)
}

extension WalletGetTransactionResponseStruct : WalletGetTransactionsResponseListenerProtocol{
    func onResult(json:String){
        print(json)
    }
}

fileprivate class TransactionsHistoryObserver:WalletGetTransactionsResponseListenerProtocol{
    func onResult(json: String) {
        
    }
}

protocol DcrTransactionsHistoryProtocol: DcrdBaseProtocol {
    var mTransactionsObserver : WalletGetTransactionResponseStruct? {get set}
    func fetchTransactions(onGotTransaction:GetTransactionsResponseCallback, onFailure:GetTransactionsResponseFailureCallback)
}

extension DcrTransactionsHistoryProtocol {
    func fetchTransactions(onGotTransaction:GetTransactionsResponseCallback, onFailure:GetTransactionsResponseFailureCallback){
        try! wallet?.getTransactions(mTransactionsObserver!)
    }
}
