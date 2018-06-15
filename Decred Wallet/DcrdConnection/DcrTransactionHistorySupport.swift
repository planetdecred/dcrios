//
//  DcrTransactionHistorySupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Wallet
    
protocol DcrTransactionsHistoryProtocol: DcrdBaseProtocol {
    var mTransactionsObserveHub: GetTransactionObserveHub?{get set}
    mutating func addObserver(notificationObserver:WalletGetTransactionsResponseProtocol)
    mutating func fetchTransactions()
}

extension DcrTransactionsHistoryProtocol {
    mutating func addObserver(notificationObserver:WalletGetTransactionsResponseProtocol){
       mTransactionsObserveHub?.subscribe(forNotifications: notificationObserver)
    }
    mutating func fetchTransactions(){
        do{
            _ = try wallet?.getTransactions(mTransactionsObserveHub)
        }catch let error{
            print("Fetch transactions error: %@", error.localizedDescription)
        }
    }
}
