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
                try WalletLoader.shared.multiWallet.politeia?.sync(self)
            } catch let error {
                print("PoliteiaNotification sync Error:", error.localizedDescription)
            }
        }
    }
}

extension PoliteiaNotification: DcrlibwalletPoliteiaNotificationListenerProtocol {
    func onNewProposal(_ proposalID: Int, censorshipToken: String?) {
        print("onNewProposal:", proposalID)
        if (WalletLoader.shared.multiWallet.isPoliteiaNotificationEnabled()) {
            NotificationsManager.shared.proposalNotification(category: .newProposal, message: "There is a new proposal",censorshipToken: censorshipToken)
        }
    }
    
    func onVoteFinished(_ proposalID: Int, censorshipToken: String?) {
        print("onVoteFinished:", proposalID)
        if (WalletLoader.shared.multiWallet.isPoliteiaNotificationEnabled()) {
            NotificationsManager.shared.proposalNotification(category: .voteProposalFinish, message: "Vote for proposal has finished", censorshipToken: censorshipToken)
        }
    }
    
    func onVoteStarted(_ proposalID: Int, censorshipToken: String?) {
        print("onVoteStarted:", proposalID)
        if (WalletLoader.shared.multiWallet.isPoliteiaNotificationEnabled()) {
            NotificationsManager.shared.proposalNotification(category: .voteProposalStarted, message: "Vote for a proposal has started", censorshipToken: censorshipToken)
        }
    }
}
