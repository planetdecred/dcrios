//
//  PoliteiaNotification.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/24/20.
//  Copyright © 2020 Decred. All rights reserved.
//

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
        NotificationsManager.shared.proposalNotification(category: .newProposal, message: "New proposal with token \(censorshipToken ?? "")")
    }
    
    func onVoteFinished(_ proposalID: Int, censorshipToken: String?) {
        print("onVoteFinished:", proposalID)
        NotificationsManager.shared.proposalNotification(category: .voteProposalFinish, message: "Vote finished for proposal with token \(censorshipToken ?? "")")
    }
    
    func onVoteStarted(_ proposalID: Int, censorshipToken: String?) {
        print("onVoteStarted:", proposalID)
        NotificationsManager.shared.proposalNotification(category: .voteProposalStarted, message: "Vote started for proposal with token \(censorshipToken ?? "")")
    }
}
