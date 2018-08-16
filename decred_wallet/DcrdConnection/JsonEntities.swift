//
//  JsonEntities.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation

struct BalanceEntity : Decodable{
    var Total: Int64  = 0
    var Spendable: Int64 = 0
    var ImmatureReward: Int64 = 0
    var ImmatureStakeGeneration: Int64 = 0
    var LockedByTickets: Int64 = 0
    var VotingAuthority: Int64 = 0
    var UnConfirmed: Int64 = 0
}

extension BalanceEntity{
    var dcrTotal : Int64{
        get{
            return Total / 100000000
        }
    }
    var dcrSpendable: Int64 {
        get{
            return Spendable / 100000000
        }
    }
    var dcrImmatureReward: Int64 {
        get{
            return ImmatureReward / 100000000
        }
    }
    var dcrImmatureStakeGeneration: Int64 {
        get{
            return ImmatureStakeGeneration / 100000000
        }
    }
    var dcrLockedByTickets: Int64 {
        get{
            return LockedByTickets / 100000000
        }
    }
    var dcrVotingAuthority: Int64 {
        get{
            return VotingAuthority / 100000000
        }
    }
    var dcrUnConfirmed: Int64 {
        get{
            return UnConfirmed / 100000000
        }
    }
}

struct AccountsEntity : Decodable{
    var Number : Int32 = 0
    var Name = "default"
    var Balance : BalanceEntity?
    var TotalBalance : Int64 = 0
    var ExternalKeyCount = 20
    var InternalKeyCount = 20
    var ImportedKeyCount = 0
}

extension AccountsEntity {
    var dcrTotalBalance : Int64 {
        get {
            return TotalBalance / 100000000
        }
    }
}

struct GetAccountResponse : Decodable {
    var Count = 0
    var ErrorMessage = ""
    var ErrorCode = 0
    var ErrorOccurred = false
    var Acc : [AccountsEntity] = []
    var CurrentBlockHash = ""
    var CurrentBlockHeight = 0
}
struct GroceryProduct: Codable {
    var name: String
    var points: Int
    var description: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.points = try values.decodeIfPresent(Int.self, forKey: .points) ?? 0
        self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
}

struct GetTransactionResponse : Codable {
    var Transactions:[Transaction]
    var ErrorOccurred: Bool
    var ErrorMessage : String
    init(from decoder: Decoder) throws {
        let values  = try decoder.container(keyedBy: CodingKeys.self)
        self.Transactions = try values.decodeIfPresent([Transaction].self, forKey: .Transactions) ?? [Transaction]()
        self.ErrorOccurred = try values.decodeIfPresent(Bool.self, forKey: .ErrorOccurred) ?? false
        self.ErrorMessage = (try values.decodeIfPresent(String.self, forKey: .ErrorMessage)) ?? ""
        
    }
}

struct Transaction : Codable {
    var Hash: String
    var Transaction: String?
    var Fee :Int
    var Direction: Int
    var Timestamp:UInt64
    var `Type` :String
    var Amount: Int64
    var Status : String
    var Height: Int
    var Debits:[Debit]
    var Credits:[Credit]
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Hash = try values.decodeIfPresent(String.self, forKey: .Hash) ?? ""
        self.Transaction = try values.decodeIfPresent(String.self, forKey: .Transaction) ?? ""
        self.Fee = try values.decodeIfPresent(Int.self, forKey: .Fee) ?? 0
        self.Direction = try values.decodeIfPresent(Int.self, forKey: .Direction) ?? 0
        self.Timestamp = try values.decodeIfPresent(UInt64.self, forKey: .Timestamp) ?? 0
        self.Type = try values.decodeIfPresent(String.self, forKey: .Type) ?? "REGULAR"
        self.Amount = (try values.decodeIfPresent(Int64.self, forKey: .Amount) ?? 0)
        self.Status = try values.decodeIfPresent(String.self, forKey: .Status) ?? ""
        self.Height = try values.decodeIfPresent(Int.self, forKey: .Height) ?? 0
        self.Debits = try values.decodeIfPresent([Debit].self, forKey: .Debits) ?? [Debit]()
        self.Credits = try values.decodeIfPresent([Credit].self, forKey: .Credits) ?? [Credit]()
    }
    
    
}

struct Credit : Codable{
    var Index: Int64
    var Account: Int64
    var Internal: Bool
    var Amount: Int64
    var Address :String
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Index = (try values.decodeIfPresent(Int64.self, forKey: .Index) ?? 0)
         self.Account = try values.decodeIfPresent(Int64.self, forKey: .Account) ?? 0
         self.Internal = try values.decodeIfPresent(Bool.self, forKey: .Internal) ?? false
         self.Amount = try values.decodeIfPresent(Int64.self, forKey: .Amount) ?? 0
         self.Address = try values.decodeIfPresent(String.self, forKey: .Address) ?? ""
    }
    
    
}

extension Credit {
    var dcrAmount : Int64 {
        get {
            return Amount / 100000000
        }
    }
}

struct Debit : Codable{
    var Index: Int64 = 0
    var PreviousAccount: Int64 = 0
    var PreviousAmount: Int64 = 0
    var AccountName = ""
    
   // var Address = ""
}

extension Debit {
    var dcrAmount : Int64 {
        get {
            return PreviousAmount / 100000000
        }
    }
}

extension GetTransactionResponse{
    var transactionsTimeline : [Transaction] {
        let timeline = Transactions.sorted(by: { (transaction1, transaction2) -> Bool in
            return transaction1.Timestamp > transaction2.Timestamp
        })
        return timeline
    }
    func transaction(by hash:String) -> Transaction?{
        return Transactions.filter({$0.Hash == hash}).first
    }
}


