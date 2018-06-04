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
    var onSuccess:GetTransactionsResponseCallback? {get set}
    var onFailure:GetTransactionsResponseFailureCallback? {get set}
}

class GetTransactionResponseListenerHelper:WalletGetTransactionsResponseListenerProtocol{
    var onSuccess: GetTransactionsResponseCallback?
    var onFailure: GetTransactionsResponseFailureCallback?
    static let instance = GetTransactionResponseListenerHelper()
}

extension WalletGetTransactionResponseStruct {
    func add(successCallback:@escaping GetTransactionsResponseCallback){
        GetTransactionResponseListenerHelper.instance.onSuccess = successCallback
    }
    func add(failureCallback:@escaping GetTransactionsResponseFailureCallback){
        GetTransactionResponseListenerHelper.instance.onFailure = failureCallback
    }
    func onResult(json:String) {
        let transaction = try! JSONDecoder().decode(JsonTransaction.self, from:json.data(using: .utf8)!)
        GetTransactionResponseListenerHelper.instance.onSuccess!(transaction)
    }
}

protocol DcrTransactionsHistoryProtocol: DcrdBaseProtocol {
    var mTransactionsObserver : WalletGetTransactionResponseStruct? {get set}
    mutating func fetchTransactions(onGotTransaction:@escaping GetTransactionsResponseCallback, onFailure:@escaping GetTransactionsResponseFailureCallback)
}

extension DcrTransactionsHistoryProtocol {
    mutating func fetchTransactions(onGotTransaction:@escaping GetTransactionsResponseCallback, onFailure:@escaping GetTransactionsResponseFailureCallback){
        mTransactionsObserver = WalletCreateGetTransactionResponse()
        mTransactionsObserver?.add(successCallback:onGotTransaction)
        mTransactionsObserver?.add(failureCallback:onFailure)
        do{
            try wallet?.getTransactions(mTransactionsObserver!)
        }catch let error{
            onFailure(error)
        }
    }
}
