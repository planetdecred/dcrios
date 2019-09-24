//
//  TransactionNotification.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Dcrlibwallet
import UserNotifications

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
    
    var newTxHashes: [String] = [String]()
    
    func startListeningForNotifications() {
        AppDelegate.walletLoader.wallet?.transactionNotification(self)
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
        self.confirmedTransactionNotificationListeners.removeValue(forKey: identifier)
    }
    
    func newTxNotification(_ transaction: String?) {
        let tx = try? JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        if tx == nil || self.newTxHashes.contains(tx!.hash) {
            return
        }
        self.newTxHashes.append(tx!.hash)
        
        if tx!.fee == 0 {
            let notification = UNMutableNotificationContent()
            notification.title = LocalizedStrings.newTransaction
            notification.body = "\(LocalizedStrings.youReceived) \(tx!.dcrAmount.round(8).description) DCR"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "TxnIdentifier", content: notification, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

extension TransactionNotification: DcrlibwalletTransactionListenerProtocol {
    func onBlockAttached(_ height: Int32, timestamp: Int64) {
        for (_, blockNotificationListener) in self.blockNotificationListeners {
            blockNotificationListener.onBlockAttached(height, timestamp: timestamp)
        }
    }
    
    func onTransaction(_ transaction: String?) {
        for (_, transactionNotificationListener) in self.transactionNotificationListeners {
            transactionNotificationListener.onTransaction(transaction)
        }
        
        if Settings.incomingNotificationEnabled {
            self.newTxNotification(transaction)
        }
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
        for (_, confirmedTransactionNotificationListener) in self.confirmedTransactionNotificationListeners {
            confirmedTransactionNotificationListener.onTransactionConfirmed(hash, height: height)
        }
    }
}
