//
//  TransactionNotification.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Dcrlibwallet
import UserNotifications

enum NotificationAlert: String {
    case none
    case silent
    case vibrationOnly
    case soundOnly
    case soundAndVibration
    
    var localizedString: String {
        switch self {
        case .none:
            return LocalizedStrings.none

        case .silent:
            return LocalizedStrings.none

        case .vibrationOnly:
            return LocalizedStrings.none

        case .soundOnly:
            return LocalizedStrings.none

        case .soundAndVibration:
            return LocalizedStrings.none
        }
    }
}

protocol NewBlockNotificationProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32)
}

protocol NewTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?)
}

protocol ConfirmedTransactionNotificationProtocol {
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32)
}

class TransactionNotification: NSObject {
    static let shared = TransactionNotification()
    
    var newTxHashes: [String] = [String]()
    
    func startListeningForNotifications() {
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")
    }
    
    func newTxNotification(_ transaction: String?) {
        let tx = try? JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        if tx == nil || self.newTxHashes.contains(tx!.hash) {
            return
        }
        self.newTxHashes.append(tx!.hash)
        
        guard let affectedWallet = WalletLoader.shared.multiWallet.wallet(withID: tx!.walletID) else {
            return
        }
        
        if tx!.fee == 0 && WalletSettings(for: affectedWallet).txNotificationAlert != .none {
            let notification = UNMutableNotificationContent()
            notification.title = LocalizedStrings.newTransaction
            notification.body = "\(LocalizedStrings.youReceived) \(tx!.dcrAmount.round(8).description) DCR"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "TxnIdentifier", content: notification, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

extension TransactionNotification: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onTransaction(_ transaction: String?) {
        if Settings.incomingNotificationEnabled {
            self.newTxNotification(transaction)
        }
    }
    
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
        // View Controllers requiring this update should call
        // `try? AppDelegate.walletLoader.multiWallet.add(self, uniqueIdentifier: "\(self)")`
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
        // View Controllers requiring this update should call
        // `try? AppDelegate.walletLoader.multiWallet.add(self, uniqueIdentifier: "\(self)")`
    }
}
