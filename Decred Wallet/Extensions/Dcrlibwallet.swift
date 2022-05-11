//
//  Dcrlibwallet.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
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
        
        return Utils.ageString(fromTimestamp: self.currentHeaderTimestamp)
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
        // deprecated feature
    }
    
    var isDefault: Bool {
        // deprecated feature
        return false
    }
    
    var isHidden: Bool {
        // deprecated feature
        return false
    }
    
    var isMixerMixedAccount: Bool {
        let wallet = WalletLoader.shared.multiWallet!.wallet(withID: self.walletID)!
        return wallet.readInt32ConfigValue(forKey: DcrlibwalletAccountMixerMixedAccount, defaultValue: -1) == number
    }
    
    var isMixerUnmixedAccount: Bool {
        let wallet = WalletLoader.shared.multiWallet!.wallet(withID: self.walletID)!
        return wallet.readInt32ConfigValue(forKey: DcrlibwalletAccountMixerUnmixedAccount, defaultValue: -1) == number
    }
    
    var dcrTotalBalance: Double {
        return DcrlibwalletAmountCoin(self.totalBalance)
    }
    
    var dcrSpendableBalance: Double {
        return self.balance?.dcrSpendable ?? 0.0
    }
}

extension DcrlibwalletWallet {
    var accounts: [DcrlibwalletAccount] {
        var accounts = [DcrlibwalletAccount]()
        do {
            let accountsIterator = try self.accountsIterator()
            while let account = accountsIterator.next() {
                accounts.append(account)
            }
        } catch let error {
            print("Error fetching wallet accounts: \(error.localizedDescription)")
        }
        return accounts
    }
    
    var totalWalletBalance: Double {
        return self.accounts.filter({ !$0.isHidden }).map({ $0.dcrTotalBalance }).reduce(0,+)
    }
    
    func currentRecieveAddress(for accountNumber: Int32) -> String {
        var error: NSError?
        let currentAddress = self.currentAddress(accountNumber, error: &error)
        if error != nil {
            print("wallet.currentAddress error: \(error!.localizedDescription)")
        }
        return currentAddress
    }

    func transactionsCount(forTxFilter txFilter: Int32) -> Int {
        let intPointer = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        defer {
            intPointer.deallocate()
        }
        
        do {
            try self.countTransactions(txFilter, ret0_: intPointer)
        } catch let error {
            print("count tx error:", error.localizedDescription)
        }

        return intPointer.pointee
    }

    func transactionHistory(offset: Int32, count: Int32 = 0, filter: Int32 = DcrlibwalletTxFilterAll, newestFirst:Bool = true) -> [Transaction]? {
        var error: NSError?
        let allTransactionsJson = self.getTransactions(offset, limit: count, txFilter: filter, newestFirst: newestFirst, error: &error)
        if error != nil {
            print("wallet.getTransactions error:", error!.localizedDescription)
            return nil
        }
        
        if allTransactionsJson.isEmpty {
            return []
        }

        var transactions: [Transaction]?
        do {
            transactions = try JSONDecoder().decode([Transaction].self, from: allTransactionsJson.data(using: .utf8)!)
        } catch let error {
            print("decode allTransactionsJson error:", error.localizedDescription)
        }
        
        if transactions != nil {
            // Check if there are new transactions since last time wallet history was displayed.
            let lastTxHash = self.readStringConfigValue(forKey: DcrlibwalletLastTxHashConfigKey, defaultValue: "")
            for i in 0..<transactions!.count {
                if transactions![i].hash == lastTxHash {
                    // We've hit the last viewed tx. No need to animate this tx or futher txs.
                    break
                }
                transactions![i].animate = true
            }
            
            // Save hash for tx index 0 as last viewed tx hash.
            self.setStringConfigValueForKey(DcrlibwalletLastTxHashConfigKey, value: transactions![0].hash)
        }
        
        return transactions
    }
    
    func hasAccountsImported() -> Bool {
        let names: [String] = accounts.map {
            return $0.name
        }
        
        return names.contains("imported")
    }
    
    func getAccountsRaw() -> Int {
        do {
            return try getAccountsRaw().count
        } catch {
            return 0
        }
    }
}

extension DcrlibwalletPoliteia {
    func getPoliteias(category: PoliteiaCategory = PoliteiaCategory.pre, offset: Int32 = 0, limit: Int32 = 20, newestFirst: Bool = true) -> (Array<Politeia>?, NSError?) {
        var error: NSError?
        let politeias = self.getProposals(category.rawValue, offset: offset, limit: limit, newestFirst: newestFirst, error: &error)
        if error != nil {
            print("getProposals error: ", error!.localizedDescription)
            return (nil, error)
        }
        
        if politeias.isEmpty {
            return ([], nil)
        }

        do {
            let response = try JSONDecoder().decode(Array<Politeia>.self, from: politeias.data(using: .utf8)!)
            return (response, nil)
        } catch let error as NSError {
            print("decode allPoliteia error:", error.localizedDescription)
            return (nil, error)
        }
    }
    
    func categoryCount(category: PoliteiaCategory) -> String {
        let int32Pointer = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        defer {
            int32Pointer.deallocate()
        }
        
        do {
            try self.count(category.rawValue, ret0_: int32Pointer)
        } catch let error {
            print("count tx error:", error.localizedDescription)
        }
        return "\(category.description) (\(int32Pointer.pointee))"
    }
    
    func detailPoliteia(_ id: Int) -> (Politeia?, NSError?) {
        do {
            let politeia = try self.getProposalByIDRaw(id)
            return (Politeia(politeia), nil)
        } catch let error as NSError {
            print("decode allPoliteia error:", error.localizedDescription)
            return (nil, error)
        }
    }
}

extension DcrlibwalletMultiWallet {
    var totalBalance: Double {
        var totalBalance: Double = 0
        let walletsIterator = self.walletsIterator()
        while let wallet = walletsIterator?.next() {
            totalBalance += wallet.totalWalletBalance
        }
        return totalBalance
    }

    func transactionHistory(offset: Int32, count: Int32 = 0, filter: Int32 = DcrlibwalletTxFilterAll, newestFirst:Bool = true) -> [Transaction]? {
        var error: NSError?
        let allTransactionsJson = self.getTransactions(offset, limit: count, txFilter: filter, newestFirst: newestFirst, error: &error)
        if error != nil {
            print("multiwallet.getTransactions error:", error!.localizedDescription)
            return nil
        }

        if allTransactionsJson.isEmpty {
            return []
        }

        var transactions: [Transaction]?
        do {
            transactions = try JSONDecoder().decode([Transaction].self, from: allTransactionsJson.data(using: .utf8)!)
        } catch let error {
            print("decode multiwallet transactions json error:", error.localizedDescription)
        }

        if transactions != nil && transactions!.count > 0 {
            // Check if there are new transactions since last time wallet history was displayed.
            let lastTxHash = self.readStringConfigValue(forKey: DcrlibwalletLastTxHashConfigKey)
            for i in 0..<transactions!.count {
                if transactions![i].hash == lastTxHash {
                    // We've hit the last viewed tx. No need to animate this tx or futher txs.
                    break
                }
                transactions![i].animate = true
            }
            
            // Save hash for tx index 0 as last viewed tx hash.
            self.setStringConfigValueForKey(DcrlibwalletLastTxHashConfigKey, value: transactions![0].hash)
        }

        return transactions
    }
    
    func getPeersInfo() -> ([PeerInfo]?, NSError?) {
        var error: NSError?
        let peers = self.peerInfo(&error)
        print(peers)
        if error != nil {
            print("multiwallet.getPeerInfo error:", error!.localizedDescription)
            return (nil, error)
        }
        
        if peers.isEmpty {
            return ([], nil)
        }
        
        var listPeers: [PeerInfo]?
        
        do {
            listPeers = try JSONDecoder().decode([PeerInfo].self, from: peers.data(using: .utf8)!)
        } catch let error as NSError {
            print("decode multiwallet peer json error:", error.localizedDescription)
            return (nil, error)
        }
        return (listPeers, nil)
    }
}

extension DcrlibwalletCFiltersFetchProgressReport {
    var blockRemaining: String {
        let blRemaining = self.totalCFiltersToFetch - self.currentCFilterHeight
        return String(format: LocalizedStrings.cfiltersLeft, blRemaining)
    }
}
