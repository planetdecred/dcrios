//
//  Dcrlibwallet.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 13/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import Dcrlibwallet

extension DcrlibwalletGeneralSyncProgress {
    var totalTimeRemaining: String {
        let minutes = self.totalTimeRemainingSeconds / 60
        if minutes > 0 {
            return "\(minutes) min"
        }
        return "\(self.totalTimeRemainingSeconds) sec"
    }
}

extension DcrlibwalletHeadersFetchProgressReport {
    var bestBlockAge: String {
        if self.currentHeaderTimestamp == 0 {
            return ""
        }
        
        let nowSeconds = Date().millisecondsSince1970 / 1000
        let hoursBehind = Float(nowSeconds - self.currentHeaderTimestamp) / Float(Utils.TimeInSeconds.Hour)
        let daysBehind = Int64(round(hoursBehind / 24.0))
        
        if daysBehind < 1 {
            return "<1 day"
        } else if daysBehind == 1 {
            return "1 day"
        } else {
            return "\(daysBehind) days"
        }
    }
}

extension DcrlibwalletLibWallet {
    func walletAccounts(confirmations: Int32) -> [WalletAccount] {
        do {
            var getAccountsError: NSError?
            let accountsJson = self.getAccounts(confirmations, error: &getAccountsError)
            if getAccountsError != nil {
                throw getAccountsError!
            }
            
            let accounts = try JSONDecoder().decode(WalletAccounts.self, from: accountsJson.utf8Bits)
            return accounts.Acc
        } catch let error {
            print("Error fetching wallet accounts: \(error.localizedDescription)")
            return [WalletAccount]()
        }
    }
    
    func totalWalletBalance(confirmations: Int32 = 0) -> Double {
        return self.walletAccounts(confirmations: confirmations).filter({ !$0.isHidden }).map({ $0.dcrTotalBalance }).reduce(0,+)
    }
}
