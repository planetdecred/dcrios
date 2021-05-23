//
//  TransactionNotification.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Dcrlibwallet
import UserNotifications
import AVFoundation

enum NotificationAlert: String, CaseIterable {
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
            return LocalizedStrings.silent

        case .vibrationOnly:
            return LocalizedStrings.vibrationOnly

        case .soundOnly:
            return LocalizedStrings.soundOnly

        case .soundAndVibration:
            return LocalizedStrings.soundAndVibration
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
    var player: AVAudioPlayer?
    var lastBeepHeight: Int32 = -1
    
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
        
        if tx!.direction == DcrlibwalletTxDirectionReceived && WalletSettings(for: affectedWallet).txNotificationAlert != .none {
            let notification = UNMutableNotificationContent()
            var title: String {
                switch tx!.type {
                case DcrlibwalletTxTypeVote:
                    if WalletLoader.shared.multiWallet.openedWalletsCount() > 1 {
                        return String(format: LocalizedStrings.walletTicketVoted, affectedWallet.name)
                    } else {
                        return LocalizedStrings.ticketVoted
                    }
                case DcrlibwalletTxTypeRevocation:
                    if WalletLoader.shared.multiWallet.openedWalletsCount() > 1 {
                        return String(format: LocalizedStrings.walletTicketRevoked, affectedWallet.name)
                    } else {
                        return LocalizedStrings.ticketRevoked
                    }
                default:
                    if WalletLoader.shared.multiWallet.openedWalletsCount() > 1 {
                        return String(format: LocalizedStrings.walletNewTransaction, affectedWallet.name)
                    } else {
                        return LocalizedStrings.newTransaction
                    }
                }
            }
            notification.title = title
            
            var amount: String {
                switch tx!.type {
                case DcrlibwalletTxTypeVote:
                    return String(format: LocalizedStrings.voteReward, tx!.voteReward)
                case DcrlibwalletTxTypeRevocation:
                    return ""
                default:
                    return "\(LocalizedStrings.youReceived) \(tx!.dcrAmount.round(8).description) DCR"
                }
            }
            notification.body = amount
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "TxnIdentifier", content: notification, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }
            
            player.volume = 0.2
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension TransactionNotification: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onTransaction(_ transaction: String?) {
        self.newTxNotification(transaction)
    }
    
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
        // View Controllers requiring this update should call
        // `try? AppDelegate.walletLoader.multiWallet.add(self, uniqueIdentifier: "\(self)")
        if (lastBeepHeight == -1 || blockHeight > lastBeepHeight) {
            lastBeepHeight = blockHeight
            if Settings.beepNewBlocks && !WalletLoader.shared.multiWallet.isSyncing() {
                self.playSound()
            }
        }
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
        // View Controllers requiring this update should call
        // `try? AppDelegate.walletLoader.multiWallet.add(self, uniqueIdentifier: "\(self)")`
    }
}
