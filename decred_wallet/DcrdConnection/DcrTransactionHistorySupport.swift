//
//  DcrTransactionHistorySupport.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Mobilewallet

/*protocol DcrTransactionsHistoryProtocol: DcrdBaseProtocol {
    //var mTransactionsObserveHub: GetTransactionObserveHub?{get set}
   // var mTransactionUpdatesHub: TransactionNotificationsObserveHub?{get set}
   // var mTransactionBlockErrorHub: TransactionBlockNotificationObserveHub?{get set}
    mutating func addObserver(transactionsHistoryObserver:MobilewalletGetTransactionsResponseProtocol)
    mutating func addObserver(forUpdateNotifications: MobilewalletTransactionListenerProtocol)
    mutating func addObserver(forBlockError:MobilewalletBlockNotificationErrorProtocol)
    mutating func fetchTransactions()
}

extension DcrTransactionsHistoryProtocol {
    mutating func addObserver(transactionsHistoryObserver:MobilewalletGetTransactionsResponseProtocol){
       mTransactionsObserveHub?.subscribe(forNotifications: transactionsHistoryObserver)
    }
    mutating func addObserver(forUpdateNotifications: MobilewalletTransactionListenerProtocol){
        mTransactionUpdatesHub?.subscribe(forUpdateNotifications: forUpdateNotifications)
     AppContext.instance.decrdConnection?.wallet?.transactionNotification( mTransactionUpdatesHub)
    }
    mutating func addObserver(forBlockError:MobilewalletBlockNotificationErrorProtocol){
        mTransactionBlockErrorHub?.subscribe(forBlockNotifications: forBlockError)
        try? AppContext.instance.decrdConnection?.wallet?.subscribe(toBlockNotifications: mTransactionBlockErrorHub)
    }

    mutating func fetchTransactions(){
        do{
            print("fecthing transaction from protocol")
            _ = try AppContext.instance.decrdConnection?.wallet?.getTransactions(mTransactionsObserveHub)
        }catch let error{
            print("Fetch transactions error: %@", error.localizedDescription)
        }
    }
}*/
