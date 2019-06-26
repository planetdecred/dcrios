//
//  Dcrlibwallet.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

extension DcrlibwalletGeneralSyncProgress {
    var totalTimeRemaining: String {
        let minutes = self.totalTimeRemainingSeconds / 60
        if minutes > 0 {
            return String(format: LocalizedStrings.minRemaining, minutes)
        }
        return String(format: LocalizedStrings.secRemaining, self.totalTimeRemainingSeconds)
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
            return LocalizedStrings.lessThanOneday
        } else if daysBehind == 1 {
            return LocalizedStrings.oneDay
        } else {
            return String(format: LocalizedStrings.mutlipleDays, daysBehind)
        }
    }
}

extension DcrlibwalletHeadersRescanProgressReport {
    var timeRemaining: String {
        let minutes = self.rescanTimeRemaining / 60
        if minutes > 0 {
            return String(format: LocalizedStrings.minRemaining, minutes)
        }
        return String(format: LocalizedStrings.secRemaining, self.rescanTimeRemaining)
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
    
    func transactionHistory(count: Int32, completion: @escaping ([Transaction]?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                var getTransactionsError: NSError?
                let transactionsJson = AppDelegate.walletLoader.wallet?.getTransactions(count, txFilter: DcrlibwalletTxFilterAll, error: &getTransactionsError)
                if getTransactionsError != nil {
                    throw getTransactionsError!
                }
                var transactions = try JSONDecoder().decode([Transaction].self, from: transactionsJson!.utf8Bits)
                
                // Check if there are new transactions since last time wallet history was displayed.
                let lastTxHash = Settings.readOptionalValue(for: Settings.Keys.LastTxHash) ?? ""
                for i in 0..<transactions.count {
                    if transactions[i].Hash == lastTxHash {
                        // We've hit the last viewed tx. No need to animate this tx or futher txs.
                        break
                    }
                    transactions[i].Animate = true
                }
                
                // Save hash for tx index 0 as last viewed tx hash.
                Settings.setValue(transactions[0].Hash, for: Settings.Keys.LastTxHash)
                
                DispatchQueue.main.async {
                    completion(transactions)
                }
            } catch let error {
                print("tx history error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
