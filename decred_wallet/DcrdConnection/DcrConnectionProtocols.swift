//
//  DcrConnectionProtocols.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation
import Mobilewallet
import MBProgressHUD

protocol DcrdBaseProtocol {

    var wallet: MobilewalletLibWallet?{get set}
}

typealias progressHUD = MBProgressHUD?

typealias SuccessCallback = ((Int32)->Void)
typealias FailureCallback = ((Error)->Void)

protocol DcrdConnectionProtocol : DcrdBaseProtocol {
    var transactionsObserver: TransactionsObserver?{get set}
    mutating func initiateWallet()
    func connect(onSuccess:SuccessCallback, onFailure:FailureCallback,progressHud: MBProgressHUD)
    func disconnect()
    mutating func subscribeForTransactions(observer:MobilewalletTransactionListenerProtocol)
    mutating func subscribeForBlockTransaction(observer:MobilewalletBlockNotificationErrorProtocol)
}

extension DcrdConnectionProtocol{
    mutating func initiateWallet(){
        AppContext.instance.decrdConnection?.wallet = MobilewalletNewLibWallet(NSHomeDirectory() + "/Documents/dcrwallet/", "bdb")
        AppContext.instance.decrdConnection?.wallet?.initLoader()
        //openWallet()
    }
    
    func openWallet (){
        do{
            try AppContext.instance.decrdConnection?.wallet?.open()
        } catch let error{
            print(error)
        }
    }

    func connect(onSuccess:SuccessCallback, onFailure:FailureCallback,progressHud: MBProgressHUD){
        let certificate = try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/rpc.cert"))
        let username = UserDefaults.standard.string(forKey: "pref_user_name")
        let password = UserDefaults.standard.string(forKey: "pref_user_passwd")
        let address  = UserDefaults.standard.string(forKey: "pref_server_ip")
        guard certificate != nil else { return }
        
        let pHeight = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        DispatchQueue.main.async {
            progressHud.label.text = "connecting to dcrd..."
            //progressHud.show(animated: true)
        }
        
        do {
            try wallet?.startRPCClient(address, rpcUser: username, rpcPass: password, certs: certificate!)
            DispatchQueue.main.async {
                progressHud.label.text = "Discovering Addresses..."
                //progressHud.show(animated: true)
            }
            
            //Convert NSString to NSData
            try wallet?.discoverActiveAddresses()
            DispatchQueue.main.async {
                progressHud.label.text = "fetching Headers..."
                //progressHud.show(animated: true)
            }
            pHeight.initialize(to: 0)
            try wallet?.fetchHeaders(pHeight)
            try wallet?.loadActiveDataFilters()
            DispatchQueue.main.async {
                progressHud.hide(animated: true)
             
            }
           
         //   try wallet?.publishUnminedTransactions()
        } catch let error{
            DispatchQueue.main.async {
                progressHud.hide(animated: true)
                
            }
            if onFailure != nil{
                onFailure(error)
            }
            return
        }
        if onSuccess != nil {
            onSuccess(pHeight.pointee)
        }
    }
    
    func disconnect() {
        AppContext.instance.decrdConnection?.wallet?.shutdown()
    }
    
    mutating func subscribeForTransactions(observer: MobilewalletTransactionListenerProtocol) {
        AppContext.instance.decrdConnection?.wallet?.transactionNotification(observer)
    }
    
    mutating func subscribeForBlockTransaction(observer:MobilewalletBlockNotificationErrorProtocol){
        do{
            try AppContext.instance.decrdConnection?.wallet?.subscribe(toBlockNotifications: observer )
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
    func applySettings(onSuccess:SuccessCallback?, onFailure:FailureCallback?,progressHud: MBProgressHUD?){
        //disconnect()
       // openWallet()
       // connect(onSuccess:onSuccess!, onFailure:onFailure!, progressHud: progressHud!)
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
           // disconnect()
           // openWallet()
            //connect(onSuccess:{_ in }, onFailure: {_ in }, progressHud: .init()  )
            saveSettings()
        }
    }
}

protocol DecredBackendProtocol: DcrdConnectionProtocol,
                                DcrdSeedMnemonicProtocol,
                                DcrAccountsManagementProtocol,
                                DcrTransactionsHistoryProtocol,
                                DcrSettingsSupportProtocol,
                                DcrSendTransactionProtocol{}
  
class DcrdConnection : DecredBackendProtocol {
    func rescan() {
    }
    
    
    
    func applySettings(onSuccess: SuccessCallback?, onFailure: FailureCallback?) {
        
    }
    
    
    
    var mTransactionsObserver: MobilewalletGetTransactionsResponseProtocol?
    var settingsBackup: String = ""

    var mTransactionUpdatesHub: TransactionNotificationsObserveHub? = TransactionNotificationsObserveHub()
    var mTransactionBlockErrorHub: TransactionBlockNotificationObserveHub? = TransactionBlockNotificationObserveHub()
    var transactionsObserver: TransactionsObserver?
    var mTransactionsObserveHub : GetTransactionObserveHub? = GetTransactionObserveHub()
    var mBlockRescanObserverHub : BlockScanObserverHub? = BlockScanObserverHub()
    var wallet: MobilewalletLibWallet?
    required init() {
        settingsBackup = UserDefaults.standard.dictionaryRepresentation().description
    }
}


