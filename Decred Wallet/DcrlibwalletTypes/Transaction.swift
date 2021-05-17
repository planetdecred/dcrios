//
//  Transaction.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

struct Transaction: Codable {
    var walletID: Int
    var hash: String
    var type: String
    var hex: String
    var timestamp: Int64
    var blockHeight: Int32
    var daysToVoteOrRevoke: Int
    
    var version: Int32
    var lockTime: Int32
    var expiry: Int32
    var fee: Int64
    
    var direction: Int32
    var amount: Int64
    var inputs: [TxInput]
    var outputs: [TxOutput]
    
    var isMixed: Bool
    
    // Vote Info
    var voteVersion: Int32
    var lastBlockValid: Bool
    var voteBits: String
    var voteReward: Int64
    
    var wallet: DcrlibwalletWallet
    
    @nonobjc var animate: Bool
    
    private enum CodingKeys : String, CodingKey {
        case walletID, hash, type, hex, timestamp
        case blockHeight = "block_height"
        case daysToVoteOrRevoke = "days_to_vote_revoke"
        
        case version
        case lockTime = "lock_time"
        case expiry, fee
        
        case isMixed = "is_mixed"
        
        case direction, amount, inputs, outputs
        
        case voteVersion = "vote_version"
        case lastBlockValid = "last_block_valid"
        case voteBits = "vote_bits"
        case voteReward = "vote_reward"
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.walletID = try! values.decode(Int.self, forKey: .walletID)
        self.hash = try! values.decode(String.self, forKey: .hash)
        self.type = try! values.decode(String.self, forKey: .type)
        self.hex = try! values.decode(String.self, forKey: .hex)
        self.timestamp = try! values.decode(Int64.self, forKey: .timestamp)
        self.blockHeight = try! values.decode(Int32.self, forKey: .blockHeight)
        self.daysToVoteOrRevoke = try! values.decode(Int.self, forKey: .daysToVoteOrRevoke)
        
        self.version = try! values.decode(Int32.self, forKey: .version)
        self.lockTime = try! values.decode(Int32.self, forKey: .lockTime)
        self.expiry = try! values.decode(Int32.self, forKey: .expiry)
        self.fee = try! values.decode(Int64.self, forKey: .fee)
        
        self.isMixed = try! values.decode(Bool.self, forKey: .isMixed)
        
        self.direction = try! values.decode(Int32.self, forKey: .direction)
        self.amount = try! values.decode(Int64.self, forKey: .amount)
        self.inputs = try! values.decode([TxInput].self, forKey: .inputs)
        self.outputs = try! values.decode([TxOutput].self, forKey: .outputs)
        
        self.voteVersion = try! values.decode(Int32.self, forKey: .voteVersion)
        self.lastBlockValid = try! values.decode(Bool.self, forKey: .lastBlockValid)
        self.voteBits = try! values.decode(String.self, forKey: .voteBits)
        self.voteReward = try! values.decode(Int64.self, forKey: .voteReward)
        
        self.animate = false
        self.wallet = WalletLoader.shared.multiWallet.wallet(withID: self.walletID)!
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.amount)) as NSDecimalNumber
    }
    
    var dcrVoteReward: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.voteReward)) as NSDecimalNumber
    }
    
    var dcrFee: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.fee)) as NSDecimalNumber
    }

    var confirmations: Int32 {
        if self.blockHeight != -1 {
            return WalletLoader.shared.multiWallet.getBestBlock()!.height - self.blockHeight + 1
        }
        return 0
    }
    
    var receiveAccount: String? {
        var error: NSError?
        for output in self.outputs where output.accountNumber != -1 {
            if error != nil {
                return nil
            }
            return wallet.accountName(output.accountNumber, error: &error)
        }
        return nil
    }

    var receiveAddress: String? {
        for output in self.outputs where output.accountNumber != -1 {
            return output.address
        }
        return nil
    }

    var sourceAddress: String? {
        for input in self.inputs where input.accountNumber != -1 {
            return input.previousTransactionHash
        }
        return nil
    }

    var sourceAccount: String? {
        var error: NSError?
        for input in self.inputs where input.accountNumber != -1 {
            if error != nil {
                return nil
            }
            return wallet.accountName(input.accountNumber, error: &error)
        }
        return nil
    }
    
    var walletName: String? {
        for wallet in WalletLoader.shared.wallets where wallet.id_ == self.walletID {
            return wallet.name
        }
        return nil
    }
}

struct TxInput: Codable {
    var previousTransactionHash: String
    var previousTransactionIndex: Int32
    var amount: Int64
    var accountNumber: Int32
    
    private enum CodingKeys : String, CodingKey {
        case previousTransactionHash = "previous_transaction_hash"
        case previousTransactionIndex = "previous_transaction_index"
        case amount
        case accountNumber = "account_number"
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.previousTransactionHash = try! values.decode(String.self, forKey: .previousTransactionHash)
        self.previousTransactionIndex = try! values.decode(Int32.self, forKey: .previousTransactionIndex)
        self.amount = try! values.decode(Int64.self, forKey: .amount)
        self.accountNumber = try! values.decode(Int32.self, forKey: .accountNumber)
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.amount)) as NSDecimalNumber
    }
}

struct TxOutput: Codable {
    var index: Int32
    var amount: Int64
    var version: Int32
    var scriptType: String
    var address: String
    var `internal`: Bool
    var accountNumber: Int32
    
    private enum CodingKeys : String, CodingKey {
        case index, amount, version
        case scriptType = "script_type"
        case address, `internal`
        case accountNumber = "account_number"
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.index = try! values.decode(Int32.self, forKey: .index)
        self.amount = try! values.decode(Int64.self, forKey: .amount)
        self.version = try! values.decode(Int32.self, forKey: .version)
        self.scriptType = try! values.decode(String.self, forKey: .scriptType)
        self.address = try! values.decode(String.self, forKey: .address)
        self.internal = try! values.decode(Bool.self, forKey: .internal)
        self.accountNumber = try! values.decode(Int32.self, forKey: .accountNumber)
    }
    
    var dcrAmount: NSDecimalNumber {
        return Decimal(DcrlibwalletAmountCoin(self.amount)) as NSDecimalNumber
    }
}
