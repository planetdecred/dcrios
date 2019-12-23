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

extension DcrlibwalletBalance {
    var dcrTotal: Double {
        return DcrlibwalletAmountCoin(self.total)
    }

    var dcrSpendable: Double {
        return DcrlibwalletAmountCoin(self.spendable)
    }

    var dcrImmatureReward: Double {
        return DcrlibwalletAmountCoin(self.immatureReward)
    }

    var dcrImmatureStakeGeneration: Double {
        return DcrlibwalletAmountCoin(self.immatureStakeGeneration)
    }

    var dcrLockedByTickets: Double {
        return DcrlibwalletAmountCoin(self.lockedByTickets)
    }

    var dcrVotingAuthority: Double {
        return DcrlibwalletAmountCoin(self.votingAuthority)
    }

    var dcrUnConfirmed: Double {
        return DcrlibwalletAmountCoin(self.unConfirmed)
    }
}

extension DcrlibwalletAccount {
    func makeDefault() {
        Settings.setValue(self.number, for: Settings.Keys.DefaultWallet)
    }
    
    var isDefault: Bool {
        return Settings.readOptionalValue(for: Settings.Keys.DefaultWallet) == self.number
    }
    
    var isHidden: Bool {
        return Settings.readValue(for: "\(Settings.Keys.HiddenWalletPrefix)\(self.number)")
    }
    
    var dcrTotalBalance: Double {
        return DcrlibwalletAmountCoin(self.totalBalance)
    }
}

extension DcrlibwalletLibWallet {
    func walletAccounts(confirmations: Int32) -> [DcrlibwalletAccount] {
        var accounts = [DcrlibwalletAccount]()
        do {
            let accountsIterator = try self.accountsIterator(confirmations)
            while let account = accountsIterator.next() {
                accounts.append(account)
            }
        } catch let error {
            print("Error fetching wallet accounts: \(error.localizedDescription)")
        }
        return accounts
    }
    
    func totalWalletBalance(confirmations: Int32 = 0) -> Double {
        return self.walletAccounts(confirmations: confirmations).filter({ !$0.isHidden }).map({ $0.dcrTotalBalance }).reduce(0,+)
    }
    
    func transactionHistory(offset: Int32, count: Int32 = 0, filter: Int32 = DcrlibwalletTxFilterAll) -> [Transaction]? {
        guard let wallet = AppDelegate.walletLoader.wallet else {
            return nil
        }
        
        var error: NSError?
        let allTransactionsJson = wallet.getTransactions(offset, limit: count, txFilter: filter, error: &error)
        if error != nil {
            print("wallet.getTransactions error:", error!.localizedDescription)
            return nil
        }
        
        var transactions: [Transaction]?
        do {
            transactions = try JSONDecoder().decode([Transaction].self, from: allTransactionsJson.data(using: .utf8)!)
        } catch let error {
            print("decode allTransactionsJson error:", error.localizedDescription)
        }
        
        if transactions != nil {
            // Check if there are new transactions since last time wallet history was displayed.
            let lastTxHash = Settings.readOptionalValue(for: Settings.Keys.LastTxHash) ?? ""
            for i in 0..<transactions!.count {
                if transactions![i].hash == lastTxHash {
                    // We've hit the last viewed tx. No need to animate this tx or futher txs.
                    break
                }
                transactions![i].animate = true
            }
            
            // Save hash for tx index 0 as last viewed tx hash.
            Settings.setValue(transactions![0].hash, for: Settings.Keys.LastTxHash)
        }
        
        return transactions
    }
}
