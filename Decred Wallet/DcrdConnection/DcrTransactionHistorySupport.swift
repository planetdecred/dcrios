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
    
protocol DcrTransactionsHistoryProtocol: DcrdBaseProtocol {
    var mTransactionsObserveHub: GetTransactionObserveHub?{get set}
    mutating func fetchTransactions()
}

extension DcrTransactionsHistoryProtocol {
    mutating func addObserver(notificationObserver:WalletGetTransactionsResponseProtocol){
       mTransactionsObserveHub?.subscribe(forNotifications: notificationObserver)
    }
    mutating func fetchTransactions(){
        do{
            mTransactionsObserveHub = GetTransactionObserveHub()
            _ = try wallet?.getTransactions(mTransactionsObserveHub as! WalletGetTransactionsResponseProtocol)
        }catch let error{
            print("Fetch transactions error: %@", error.localizedDescription)
        }
    }
}
