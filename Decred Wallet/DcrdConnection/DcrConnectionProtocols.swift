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
    func openWallet()
    func connect(onSuccess:SuccessCallback?, onFailure:FailureCallback?)
    func disconnect()
    mutating func subscribeForTransactions(observer:WalletTransactionListenerProtocol)
    mutating func subscribeForBlockTransaction(observer:WalletBlockNotificationErrorProtocol)
}

extension DcrdConnectionProtocol{
    mutating func initiateWallet(){
        wallet = WalletNewLibWallet(NSHomeDirectory() + "/Documents")
        wallet?.initLoader()
        openWallet()
    }
    
    func openWallet (){
        do{
            try wallet?.open()
        } catch let error{
            print(error)
        }
    }
    
    func connect(onSuccess:SuccessCallback?, onFailure:FailureCallback?){
        let certificate = try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/rpc.cert"))
        let username = UserDefaults.standard.string(forKey: "pref_user_name")
        let password = UserDefaults.standard.string(forKey: "pref_user_passwd")
        let address  = UserDefaults.standard.string(forKey: "pref_server_ip")
        guard certificate != nil else { return }
        
        let pHeight = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        do {
            try wallet?.startRPCClient(address, rpcUser: username, rpcPass: password, certs: certificate!)
            try wallet?.discoverActiveAddresses(false, privPass: nil)
            try wallet?.loadActiveDataFilters()
            pHeight.initialize(to: 0)
            try wallet?.fetchHeaders(pHeight)
            try wallet?.publishUnminedTransactions()
        } catch let error{
            if onFailure != nil{
                onFailure!(error)
            }
            return
        }
        if onSuccess != nil {
            onSuccess!(pHeight.pointee)
        }
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

protocol DcrSettingsSupportProtocol:DcrdConnectionProtocol {
    var settingsBackup: String {get set}
    func applySettings(onSuccess:SuccessCallback?, onFailure:FailureCallback?)
    mutating func saveSettings()
    mutating func applySettings()
}

extension DcrSettingsSupportProtocol{
    func applySettings(onSuccess:SuccessCallback?, onFailure:FailureCallback?){
        disconnect()
        openWallet()
        connect(onSuccess:onSuccess, onFailure:onFailure)
    }
    
    mutating func saveSettings(){
        self.settingsBackup = UserDefaults.standard.dictionaryRepresentation().description
    }
    
    func isSettingsChanged() -> Bool{
        let newSettings = UserDefaults.standard.dictionaryRepresentation().description
        return newSettings != self.settingsBackup
    }
    
    mutating func applySettings(){
        if isSettingsChanged(){
            disconnect()
            openWallet()
            connect(onSuccess:nil, onFailure: nil)
            saveSettings()
        }
    }
}

protocol DecredBackendProtocol: DcrTransactionsHistoryProtocol, DcrdSeedMnemonicProtocol, DcrdCreateRestoreWalletProtocol, DcrAccountsManagementProtocol, DcrSettingsSupportProtocol {}

class DcrdConnection : DecredBackendProtocol {
    var settingsBackup: String = ""
    var mTransactionsObserver: WalletGetTransactionResponseStruct?
    var transactionsObserver: TransactionsObserver?
    var wallet: WalletLibWallet?
    required init() {
        settingsBackup = UserDefaults.standard.dictionaryRepresentation().description
    }
}


