//
//  PoliteiaNotification.swift
//  Decred Wallet
//
// Copyright © 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

class PoliteiaNotification: NSObject {
    static let shared = PoliteiaNotification()
    
    func syncPoliteia() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.politeia?.sync(DcrlibwalletPoliteiaMainnetHost)
            } catch let error {
                print("PoliteiaNotification sync Error:", error.localizedDescription)
                DispatchQueue.main.async {
                    if let navigationTabController = NavigationMenuTabBarController.instance?.view {
                        Utils.showBanner(in: navigationTabController, type: .error, text: LocalizedStrings.syncPoliteiaTryAgain)
                    }
                }
            }
        }
    }
    
    func startListeningForNotifications() {
        try? WalletLoader.shared.multiWallet.politeia?.add(self, uniqueIdentifier: "\(self)")
    }
}

extension PoliteiaNotification: DcrlibwalletProposalNotificationListenerProtocol {
    
    func onNewProposal(_ proposal: DcrlibwalletProposal?) {
        let message = "\(proposal?.name ?? "") by \(proposal?.username ?? "")"
        NotificationsManager.shared.proposalNotification(category: .newProposal, message: message, proposalId: proposal?.id_)
    }
    
    func onProposalVoteFinished(_ proposal: DcrlibwalletProposal?) {
        let message = "\(proposal?.name ?? "") by \(proposal?.username ?? "")"
        NotificationsManager.shared.proposalNotification(category: .newProposal, message: message, proposalId: proposal?.id_)
    }
    
    func onProposalVoteStarted(_ proposal: DcrlibwalletProposal?) {
        let message = "\(proposal?.name ?? "") by \(proposal?.username ?? "")"
        NotificationsManager.shared.proposalNotification(category: .newProposal, message: message, proposalId: proposal?.id_)
    }
    
    func onProposalsSynced() {
    }
}
