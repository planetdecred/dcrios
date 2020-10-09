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
    
    private let IS_SYNC_SUCCESS_KEY = "sync_politeia_success"
    
    func syncPoliteia() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.politeia?.sync()
                self.setSyncStatus(isSyncSuccess: true)
            } catch let error {
                print("PoliteiaNotification sync Error:", error.localizedDescription)
                self.setSyncStatus(isSyncSuccess: false)
                DispatchQueue.main.async {
                    if let navigationTabController = NavigationMenuTabBarController.instance?.view {
                        Utils.showBanner(in: navigationTabController, type: .error, text: "There was an error when sync politeia, please try again in Politeia")
                    }
                }
            }
        }
    }
    
    private func setSyncStatus(isSyncSuccess: Bool) {
        UserDefaults.standard.setValue(isSyncSuccess, forKey: IS_SYNC_SUCCESS_KEY)
    }
    
    func syncPoliteiaStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: IS_SYNC_SUCCESS_KEY)
    }
    
    func startListeningForNotifications() {
        try? WalletLoader.shared.multiWallet.politeia?.add(self, uniqueIdentifier: "\(self)")
    }
}

extension PoliteiaNotification: DcrlibwalletProposalNotificationListenerProtocol {
    
    func onNewProposal(_ proposalID: Int, censorshipToken: String?) {
        print("onNewProposal:", proposalID)
        NotificationsManager.shared.proposalNotification(category: .newProposal, message: "There is a new proposal",censorshipToken: censorshipToken)
    }
    
    func onProposalVoteFinished(_ proposalID: Int, censorshipToken: String?) {
        print("onProposalVoteFinished:", proposalID)
        NotificationsManager.shared.proposalNotification(category: .voteProposalFinish, message: "Vote for proposal has finished", censorshipToken: censorshipToken)
    }
    
    func onProposalVoteStarted(_ proposalID: Int, censorshipToken: String?) {
        print("onProposalVoteStarted:", proposalID)
        NotificationsManager.shared.proposalNotification(category: .voteProposalStarted, message: "Vote for a proposal has started", censorshipToken: censorshipToken)
    }
}
