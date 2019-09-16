//
//  WalletAccount.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

struct WalletAccounts: Decodable {
    var Count = 0
    var ErrorMessage = ""
    var ErrorCode = 0
    var ErrorOccurred = false
    var Acc: [WalletAccount] = []
    var CurrentBlockHash = ""
    var CurrentBlockHeight = 0
}

struct WalletAccount: Decodable {
    var Number: Int32 = 0
    var Name = "default"
    var Balance: WalletBalance?
    var TotalBalance: Int64
    var ExternalKeyCount = 20
    var InternalKeyCount = 20
    var ImportedKeyCount = 0
    
    func makeDefault() {
        Settings.setValue(self.Number, for: Settings.Keys.DefaultWallet)
    }
    
    var isDefault: Bool {
        return Settings.readOptionalValue(for: Settings.Keys.DefaultWallet) == self.Number
    }
    
    var isHidden: Bool {
        return Settings.readValue(for: "\(Settings.Keys.HiddenWalletPrefix)\(self.Number)")

    }
    
    var dcrTotalBalance: Double {
        return Double(self.TotalBalance) / 100000000.0
    }
}

struct WalletBalance: Decodable {
    var Total: Double = 0
    var Spendable: Double = 0
    var ImmatureReward: Double = 0
    var ImmatureStakeGeneration: Double = 0
    var LockedByTickets: Double = 0
    var VotingAuthority: Double = 0
    var UnConfirmed: Double = 0
    
    var dcrTotal: Double {
        return self.Total / 100000000
    }
    
    var dcrSpendable: Double {
        return self.Spendable / 100000000
    }
    
    var dcrImmatureReward: Double {
        return self.ImmatureReward / 100000000
    }
    
    var dcrImmatureStakeGeneration: Double {
        return self.ImmatureStakeGeneration / 100000000
    }
    
    var dcrLockedByTickets: Double {
        return self.LockedByTickets / 100000000
    }
    
    var dcrVotingAuthority: Double {
        return self.VotingAuthority / 100000000
    }
    
    var dcrUnConfirmed: Double {
        return self.UnConfirmed / 100000000
    }
}
