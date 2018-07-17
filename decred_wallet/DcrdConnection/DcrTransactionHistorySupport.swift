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
    var mTransactionUpdatesHub: TransactionNotificationsObserveHub?{get set}
    var mTransactionBlockErrorHub: TransactionBlockNotificationObserveHub?{get set}
    mutating func addObserver(transactionsHistoryObserver:WalletGetTransactionsResponseProtocol)
    mutating func addObserver(forUpdateNotifications: WalletTransactionListenerProtocol)
    mutating func addObserver(forBlockError:WalletBlockNotificationErrorProtocol)
    mutating func fetchTransactions()
}

extension DcrTransactionsHistoryProtocol {
    mutating func addObserver(transactionsHistoryObserver:WalletGetTransactionsResponseProtocol){
       mTransactionsObserveHub?.subscribe(forNotifications: transactionsHistoryObserver)
    }
    mutating func addObserver(forUpdateNotifications: WalletTransactionListenerProtocol){
        mTransactionUpdatesHub?.subscribe(forUpdateNotifications: forUpdateNotifications)
        wallet?.transactionNotification( mTransactionUpdatesHub)
    }
    mutating func addObserver(forBlockError:WalletBlockNotificationErrorProtocol){
        mTransactionBlockErrorHub?.subscribe(forBlockNotifications: forBlockError)
        try? wallet?.subscribe(toBlockNotifications: mTransactionBlockErrorHub)
    }

    mutating func fetchTransactions(){
        do{
            _ = try wallet?.getTransactions(mTransactionsObserveHub)
        }catch let error{
            print("Fetch transactions error: %@", error.localizedDescription)
        }
    }
}
