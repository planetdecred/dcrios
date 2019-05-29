//
//  JsonEntities.swift
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
        return UserDefaults.standard.bool(forKey: "hidden\(self.Number)")
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

struct Transaction: Codable {
    var Hash: String
    var Fee: Double
    var Direction: Int
    var Timestamp: UInt64
    var `Type`: String
    var Amount: Double
    var Status: String
    var Height: Int
    var Debits: [Debit]
    var Credits: [Credit]
    var Raw: String
    
    @nonobjc var Animate: Bool
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Hash = try values.decodeIfPresent(String.self, forKey: .Hash) ?? ""
        self.Fee = try values.decodeIfPresent(Double.self, forKey: .Fee) ?? 0.0
        self.Direction = try values.decodeIfPresent(Int.self, forKey: .Direction) ?? 0
        self.Timestamp = try values.decodeIfPresent(UInt64.self, forKey: .Timestamp) ?? 0
        self.Type = try values.decodeIfPresent(String.self, forKey: .Type) ?? "REGULAR"
        self.Amount = (try values.decodeIfPresent(Double.self, forKey: .Amount) ?? 0.0)
        self.Status = try values.decodeIfPresent(String.self, forKey: .Status) ?? ""
        self.Height = try values.decodeIfPresent(Int.self, forKey: .Height) ?? 0
        self.Debits = try values.decodeIfPresent([Debit].self, forKey: .Debits) ?? [Debit]()
        self.Credits = try values.decodeIfPresent([Credit].self, forKey: .Credits) ?? [Credit]()
        self.Raw = try values.decodeIfPresent(String.self, forKey: .Raw) ?? ""
        self.Animate = false
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(Double(self.Amount) / 1e8) as NSDecimalNumber
    }
}

struct Credit: Codable {
    var Index: Int64
    var Account: Int64
    var Internal: Bool
    var Amount: Double
    var Address: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Index = (try values.decodeIfPresent(Int64.self, forKey: .Index) ?? 0)
        self.Account = try values.decodeIfPresent(Int64.self, forKey: .Account) ?? 0
        self.Internal = try values.decodeIfPresent(Bool.self, forKey: .Internal) ?? false
        self.Amount = try values.decodeIfPresent(Double.self, forKey: .Amount) ?? 0.0
        self.Address = try values.decodeIfPresent(String.self, forKey: .Address) ?? ""
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(Double(self.Amount) / 1e8) as NSDecimalNumber
    }
}

struct Debit: Codable {
    var Index: Int64 = 0
    var PreviousAccount: Double = 0.0
    var PreviousAmount: Double = 0.0
    var AccountName = ""
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(Double(self.PreviousAmount) / 1e8) as NSDecimalNumber
    }
}

struct DecodedTransaction: Codable {
    var Hash: String
    var `Type`: String
    var Version: Int32
    var LockTime: Int32
    var Expiry: Int32
    var Inputs: [DecodedInput]
    var Outputs: [DecodedOutput]
    
    // Vote Info
    var VoteVersion: Int32
    var LastBlockValid: Bool
    var VoteBits: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.Hash = try values.decodeIfPresent(String.self, forKey: .Hash) ?? ""
        self.Type = try values.decodeIfPresent(String.self, forKey: .Type) ?? ""
        self.Version = try values.decodeIfPresent(Int32.self, forKey: .Version) ?? 0
        self.LockTime = try values.decodeIfPresent(Int32.self, forKey: .LockTime) ?? 0
        self.Expiry = try values.decodeIfPresent(Int32.self, forKey: .Expiry) ?? 0
        
        self.Inputs = try values.decodeIfPresent([DecodedInput].self, forKey: .Inputs) ?? [DecodedInput]()
        self.Outputs = try values.decodeIfPresent([DecodedOutput].self, forKey: .Outputs) ?? [DecodedOutput]()
        
        self.VoteVersion = try values.decodeIfPresent(Int32.self, forKey: .VoteVersion) ?? 0
        self.LastBlockValid = try values.decodeIfPresent(Bool.self, forKey: .LastBlockValid) ?? false
        self.VoteBits = try values.decodeIfPresent(String.self, forKey: .VoteBits) ?? ""
    }
}

struct DecodedInput: Codable {
    var PreviousTransactionHash: String
    var PreviousTransactionIndex: Int32
    var AmountIn: Int64
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(Double(self.AmountIn) / 1e8) as NSDecimalNumber
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.PreviousTransactionHash = try values.decodeIfPresent(String.self, forKey: .PreviousTransactionHash) ?? ""
        self.PreviousTransactionIndex = try values.decodeIfPresent(Int32.self, forKey: .PreviousTransactionIndex) ?? 0
        self.AmountIn = try values.decodeIfPresent(Int64.self, forKey: .AmountIn) ?? 0
    }
}

struct DecodedOutput: Codable {
    var Index: Int32
    var Value: Int64
    var Version: Int32
    var ScriptType: String
    var Addresses: [String]
    var dcrAmount: NSDecimalNumber {
        return Decimal(Double(self.Value) / 1e8) as NSDecimalNumber
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Index = try values.decodeIfPresent(Int32.self, forKey: .Index) ?? 0
        self.Value = try values.decodeIfPresent(Int64.self, forKey: .Value) ?? 0
        self.Version = try values.decodeIfPresent(Int32.self, forKey: .Version) ?? 0
        self.ScriptType = try values.decodeIfPresent(String.self, forKey: .ScriptType) ?? ""
        self.Addresses = try values.decodeIfPresent([String].self, forKey: .Addresses) ?? []
    }
}
