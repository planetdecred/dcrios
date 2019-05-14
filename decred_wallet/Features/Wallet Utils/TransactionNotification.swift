//
//  TransactionNotification.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 14/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

protocol NewBlockNotificationProtocol {
    func onBlockAttached(_ height: Int32, timestamp: Int64)
}

protocol NewTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?)
}

protocol ConfirmedTransactionNotificationProtocol {
    func onTransactionConfirmed(_ hash: String?, height: Int32)
}

class TransactionNotification: NSObject {
    var blockNotificationListeners = [String : NewBlockNotificationProtocol]()
    var transactionNotificationListeners = [String : NewTransactionNotificationProtocol]()
    var confirmedTransactionNotificationListeners = [String : ConfirmedTransactionNotificationProtocol]()
    
    override init() {
        super.init()
        print("listening for notifications")
        WalletLoader.wallet?.transactionNotification(self)
    }
    
    func registerListener(for identifier: String, newBlockListener: NewBlockNotificationProtocol) {
        self.blockNotificationListeners[identifier] = newBlockListener
    }
    
    func registerListener(for identifier: String, newTxistener: NewTransactionNotificationProtocol) {
        self.transactionNotificationListeners[identifier] = newTxistener
    }
    
    func registerListener(for identifier: String, confirmedTxListener: ConfirmedTransactionNotificationProtocol) {
        self.confirmedTransactionNotificationListeners[identifier] = confirmedTxListener
    }
    
    func deRegisterListeners(for identifier: String) {
        self.blockNotificationListeners.removeValue(forKey: identifier)
        self.transactionNotificationListeners.removeValue(forKey: identifier)
    }
}

extension TransactionNotification: DcrlibwalletTransactionListenerProtocol {
    func onBlockAttached(_ height: Int32, timestamp: Int64) {
        for (_, blockNotificationListener) in self.blockNotificationListeners {
            blockNotificationListener.onBlockAttached(height, timestamp: timestamp)
        }
    }
    
    func onTransaction(_ transaction: String?) {
        
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
        
    }
}
