//
//  JsonEntities.swift
//  Decred Wallet
//
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import Foundation

struct BalanceEntity : Decodable{
    var Total: Double = 0
    var Spendable: Double = 0
    var ImmatureReward: Double = 0
    var ImmatureStakeGeneration: Double = 0
    var LockedByTickets: Double = 0
    var VotingAuthority: Double = 0
    var UnConfirmed: Double = 0
}

extension BalanceEntity{
    var dcrTotal : Double{
        get{
            return Total / 100000000
        }
    }
    var dcrSpendable: Double {
        get{
            return Spendable / 100000000
        }
    }
    var dcrImmatureReward: Double {
        get{
            return ImmatureReward / 100000000
        }
    }
    var dcrImmatureStakeGeneration: Double {
        get{
            return ImmatureStakeGeneration / 100000000
        }
    }
    var dcrLockedByTickets: Double {
        get{
            return LockedByTickets / 100000000
        }
    }
    var dcrVotingAuthority: Double {
        get{
            return VotingAuthority / 100000000
        }
    }
    var dcrUnConfirmed: Double {
        get{
            return UnConfirmed / 100000000
        }
    }
}

struct AccountsEntity : Decodable{
    var Number : Int32 = 0
    var Name = "default"
    var Balance : BalanceEntity?
    var TotalBalance : Double = 0.0
    var ExternalKeyCount = 20
    var InternalKeyCount = 20
    var ImportedKeyCount = 0
}

extension AccountsEntity {
    var dcrTotalBalance : Double {
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

struct GetTransactionResponse : Codable {
    var Transactions:[Transaction]
    var ErrorOccurred: Bool
    var ErrorMessage : String
    init(from decoder: Decoder) throws {
        do{
            print("in decoding now ")
            let values  = try decoder.container(keyedBy: CodingKeys.self)
            self.Transactions = try values.decodeIfPresent([Transaction].self, forKey: .Transactions) ?? [Transaction.init(from: decoder)]
            self.ErrorOccurred = try values.decodeIfPresent(Bool.self, forKey: .ErrorOccurred) ?? true
            self.ErrorMessage = (try values.decodeIfPresent(String.self, forKey: .ErrorMessage)) ?? ""
            print("done my work decoding")
        }
        catch {
                print(Error.self)
            print("error decoding")
            self.Transactions =  [try Transaction.init(from: decoder)]
            self.ErrorOccurred =  false
            self.ErrorMessage =  ""
            
        }
        
    }
}

struct Transaction : Codable {
    var Hash: String
    var Transaction: String?
    var Fee :Double
    var Direction: Int
    var Timestamp:UInt64
    var `Type` :String
    var Amount: Double
    var Status : String
    var Height: Int
    var Debits:[Debit]
    var Credits:[Credit]
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Hash = try values.decodeIfPresent(String.self, forKey: .Hash) ?? ""
        self.Transaction = try values.decodeIfPresent(String.self, forKey: .Transaction) ?? ""
        self.Fee = try values.decodeIfPresent(Double.self, forKey: .Fee) ?? 0.0
        self.Direction = try values.decodeIfPresent(Int.self, forKey: .Direction) ?? 0
        self.Timestamp = try values.decodeIfPresent(UInt64.self, forKey: .Timestamp) ?? 0
        self.Type = try values.decodeIfPresent(String.self, forKey: .Type) ?? "REGULAR"
        self.Amount = (try values.decodeIfPresent(Double.self, forKey: .Amount) ?? 0.0)
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
    var Amount: Double
    var Address :String
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.Index = (try values.decodeIfPresent(Int64.self, forKey: .Index) ?? 0)
         self.Account = try values.decodeIfPresent(Int64.self, forKey: .Account) ?? 0
         self.Internal = try values.decodeIfPresent(Bool.self, forKey: .Internal) ?? false
         self.Amount = try values.decodeIfPresent(Double.self, forKey: .Amount) ?? 0.0
         self.Address = try values.decodeIfPresent(String.self, forKey: .Address) ?? ""
    }
    
    
}

extension Credit {
    var dcrAmount : Double {
        get {
            return Amount / 100000000
        }
    }
}

struct Debit : Codable{
    var Index: Int64 = 0
    var PreviousAccount: Double = 0.0
    var PreviousAmount: Double = 0.0
    var AccountName = ""
    
   // var Address = ""
}

extension Debit {
    var dcrAmount : Double {
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


