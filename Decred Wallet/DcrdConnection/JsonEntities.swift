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

struct GetTransactionResponse : Decodable {
    var Transactions:[Transaction]?
    var ErrorOccured: Bool = false
    var ErrorMessage = ""
}

struct Transaction : Decodable {
    var Hash = ""
    var Transaction = 0
    var Fee = 0
    var Timestamp:UInt64 = 0
    var `Type` = "REGULAR"
    var Amount: Int64 = 0
    var Status = ""
    var Height = 0
    var Debits:[Debit]?
    var Credits:[Credit]?
}

struct Credit : Decodable{
    var Index: Int64 = 0
    var Account: Int64 = 0
    var Internal: Bool = false
    var Amount: Int64 = 0
    var Address = ""
}

struct Debit : Decodable{
    var Index: Int64 = 0
    var Account: Int64 = 0
    var Internal: Bool = false
    var Amount: Int64 = 0
    var Address = ""
}

