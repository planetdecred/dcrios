//
//  Transaction.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

struct Transaction: Codable {
    var Hash: String
    var `Type`: String
    var Hex: String
    var Timestamp: Int64
    var BlockHeight: Int32
    
    var Version: Int32
    var LockTime: Int32
    var Expiry: Int32
    var Fee: Int64
    
    var Direction: Int32
    var Amount: Int64
    var Inputs: [TxInput]
    var Outputs: [TxOutput]
    
    // Vote Info
    var VoteVersion: Int32
    var LastBlockValid: Bool
    var VoteBits: String
    
    @nonobjc var Animate: Bool
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.Hash = try! values.decode(String.self, forKey: .Hash)
        self.Type = try! values.decode(String.self, forKey: .Type)
        self.Hex = try! values.decode(String.self, forKey: .Hex)
        self.Timestamp = try! values.decode(Int64.self, forKey: .Timestamp)
        self.BlockHeight = try! values.decode(Int32.self, forKey: .BlockHeight)
        
        self.Version = try! values.decode(Int32.self, forKey: .Version)
        self.LockTime = try! values.decode(Int32.self, forKey: .LockTime)
        self.Expiry = try! values.decode(Int32.self, forKey: .Expiry)
        self.Fee = try! values.decode(Int64.self, forKey: .Fee)
        
        self.Direction = try! values.decode(Int32.self, forKey: .Direction)
        self.Amount = try! values.decode(Int64.self, forKey: .Amount)
        self.Inputs = try! values.decode([TxInput].self, forKey: .Inputs)
        self.Outputs = try! values.decode([TxOutput].self, forKey: .Outputs)
        
        self.VoteVersion = try! values.decode(Int32.self, forKey: .VoteVersion)
        self.LastBlockValid = try! values.decode(Bool.self, forKey: .LastBlockValid)
        self.VoteBits = try! values.decode(String.self, forKey: .VoteBits)
        
        self.Animate = false
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.Amount)) as NSDecimalNumber
    }
    
    var dcrFee: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.Fee)) as NSDecimalNumber
    }
}

struct TxInput: Codable {
    var PreviousTransactionHash: String
    var PreviousTransactionIndex: Int32
    var Amount: Int64
    var AccountName: String
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.PreviousTransactionHash = try! values.decode(String.self, forKey: .PreviousTransactionHash)
        self.PreviousTransactionIndex = try! values.decode(Int32.self, forKey: .PreviousTransactionIndex)
        self.Amount = try! values.decode(Int64.self, forKey: .Amount)
        self.AccountName = try! values.decode(String.self, forKey: .AccountName)
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.Amount)) as NSDecimalNumber
    }
}

struct TxOutput: Codable {
    var Index: Int32
    var Amount: Int64
    var Version: Int32
    var ScriptType: String
    var Address: String
    var Internal: Bool
    var AccountName: String
    var AccountNumber: Int32
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.Index = try! values.decode(Int32.self, forKey: .Index)
        self.Amount = try! values.decode(Int64.self, forKey: .Amount)
        self.Version = try! values.decode(Int32.self, forKey: .Version)
        self.ScriptType = try! values.decode(String.self, forKey: .ScriptType)
        self.Address = try! values.decode(String.self, forKey: .Address)
        self.Internal = try! values.decode(Bool.self, forKey: .Internal)
        self.AccountName = try! values.decode(String.self, forKey: .AccountName)
        self.AccountNumber = try! values.decode(Int32.self, forKey: .AccountNumber)
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.Amount)) as NSDecimalNumber
    }
}
