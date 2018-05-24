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

protocol DcrdConnectionProtocol : DcrdBaseProtocol {
    var transactionsObserver: TransactionsObserver?{get set}
    mutating func initiateWallet()
    func connect()-> Bool
    func disconnect()
    mutating func subscribeForTransactions(observer:WalletTransactionListenerProtocol)
    mutating func subscribeForBlockTransaction(observer:WalletBlockNotificationErrorProtocol)
    
}

extension DcrdConnectionProtocol{
    mutating func initiateWallet(){
        wallet = WalletNewLibWallet(NSHomeDirectory() + "/Documents")
        wallet?.initLoader()
    }
    
    func connect() -> Bool {
        let certificate = try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/rpc.cert"))
        let username = UserDefaults.standard.string(forKey: "pref_user_name")
        let password = UserDefaults.standard.string(forKey: "pref_user_passwd")
        let address  = UserDefaults.standard.string(forKey: "pref_server_ip")
        
        do {
            try wallet?.startRPCClient(address, rpcUser: username, rpcPass: password, certs: certificate!)
        } catch {
            return false
        }
        return true
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

protocol DecredBackendProtocol: DcrdConnectionProtocol, DcrdSeedMnemonicProtocol, DcrdCreateRestoreWalletProtocol {}

class DcrdConnection : DecredBackendProtocol {
    
    var transactionsObserver: TransactionsObserver?
    var wallet: WalletLibWallet?
}


