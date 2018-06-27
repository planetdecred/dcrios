//
//  DcrObservers.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Wallet

// MARK: - endpoint listener protocols
protocol TransactionObserverProtocol {
    var transactions:[String]?{get set}
    func populateTransaction(transaction:String)
    func refresh()
}

protocol TransactionBlockObserverProtocol {
    func onBlockError(error:Error)
}

// MARK: - internal listener protocols
protocol WalletTransactionBlockListenerProtocol {
    var onBlockTransactionError:((Error)->Void)?{get set}
}

// MARK: - Observers

struct ObserversListener:WalletTransactionBlockListenerProtocol{
    var onBlockTransactionError: ((Error)->Void)?
    static var instance = ObserversListener()
}

class TransactionsObserver {
    fileprivate var listener: TransactionObserverProtocol?
    fileprivate let mUpcomingTransactionListener = WalletTransactionListener()
    fileprivate let mTransactionListener = WalletGetTransactionsResponse()
    init(listener:TransactionObserverProtocol) {
        self.listener = listener
    }
    func subscribe(){
        AppContext.instance.decrdConnection?.subscribeForTransactions(observer: mUpcomingTransactionListener)
    }
}

class TransactionsBlockObserver {
    fileprivate var listener:TransactionBlockObserverProtocol?
    //fileprivate var mbBlockNotofication = WalletCreateTransactionsBlockListener()
    init(listener: TransactionBlockObserverProtocol) {
        self.listener = listener
//        self.mbBlockNotofication?.onBlockTransactionError = {(error) in
//            self.listener?.onBlockError(error: error)
//        }
    }
    func subscribe(){
        //AppContext.instance.decrdConnection?.subscribeForBlockTransaction(observer: mbBlockNotofication!)
    }
}
