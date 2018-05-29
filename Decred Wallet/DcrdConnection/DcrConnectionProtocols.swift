//
//  DcrConnectionProtocols.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Wallet

protocol DcrdBaseProtocol {
    var wallet: WalletLibWallet?{get set}
}

typealias SuccessCallback = ((Int32)->Void)
typealias FailureCallback = ((Error)->Void)

protocol DcrdConnectionProtocol : DcrdBaseProtocol {
    var transactionsObserver: TransactionsObserver?{get set}
    mutating func initiateWallet()
    func connect()-> Bool //obsolete
    func connect(onSuccess:SuccessCallback, onFailure:FailureCallback)
    func disconnect()
    mutating func subscribeForTransactions(observer:WalletTransactionListenerProtocol)
    mutating func subscribeForBlockTransaction(observer:WalletBlockNotificationErrorProtocol)
}

extension DcrdConnectionProtocol{
    mutating func initiateWallet(){
        wallet = WalletNewLibWallet(NSHomeDirectory() + "/Documents")
        wallet?.initLoader()
        do{
            try wallet?.open()
        } catch let error{
            print(error)
        }
    }
    
    func connect() -> Bool {
        assert(true, "'connect()' method is obsolete. Use 'connect(onSuccess:SuccessCallback, onFailure:FailureCallback)' instead")
        return false
    }
    
    func connect(onSuccess:SuccessCallback, onFailure:FailureCallback){
        let certificate = try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/rpc.cert"))
        let username = UserDefaults.standard.string(forKey: "pref_user_name")
        let password = UserDefaults.standard.string(forKey: "pref_user_passwd")
        let address  = UserDefaults.standard.string(forKey: "pref_server_ip")
        
        let pHeight = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        do {
            try wallet?.startRPCClient(address, rpcUser: username, rpcPass: password, certs: certificate!)
            try wallet?.discoverActiveAddresses(false, privPass: nil)
            try wallet?.loadActiveDataFilters()
            pHeight.initialize(to: 0)
            try wallet?.fetchHeaders(pHeight)
            try wallet?.publishUnminedTransactions()
        } catch let error{
            onFailure(error)
        }
        onSuccess(pHeight.pointee)
    }
    
    func disconnect() {
        wallet?.shutdown()
    }
    
    mutating func subscribeForTransactions(observer: WalletTransactionListenerProtocol) {
        wallet?.transactionNotification(observer)
    }
    
    mutating func subscribeForBlockTransaction(observer:WalletBlockNotificationErrorProtocol){
        do{
            try wallet?.subscribe(toBlockNotifications: observer )
        } catch let error{
            print(error)
        }
    }
}

protocol DecredBackendProtocol: DcrdConnectionProtocol, DcrdSeedMnemonicProtocol, DcrdCreateRestoreWalletProtocol, DcrAccountsManagementProtocol {}

class DcrdConnection : DecredBackendProtocol {
    var transactionsObserver: TransactionsObserver?
    var wallet: WalletLibWallet?
}


