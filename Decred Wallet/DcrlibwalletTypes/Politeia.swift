//
//  Politeia.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/14/20.
//  Copyright © 2020 Decred. All rights reserved.
//

import Foundation
import Dcrlibwallet

struct Politeia: Codable {
    var ID: Int
    var category: Int
    var name: String
    var state: Int
    var status: Int
    var timestamp: Int64
    var userid: String
    var username: String
    var publickey: String
    var signature: String
    var numcomments: Int
    var version: String
    var publishedat: Date
    var files: Array<PFile>
    var metadata: Array<PoliteiaMetadata>
    var votestatus: PVotestatus?
    var votesummary: PVotesummary
    var censorshiprecord: PCensorShipRecord
    
    private enum CodingKeys : String, CodingKey {
        case name, state, status, timestamp, userid, username, publickey, signature, numcomments, version, publishedat, files, metadata, censorshiprecord, ID, category, votestatus, votesummary
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.ID = try! values.decode(Int.self, forKey: .ID)
        self.category = try! values.decode(Int.self, forKey: .category)
        self.name = try! values.decode(String.self, forKey: .name)
        self.state = try! values.decode(Int.self, forKey: .state)
        self.status = try! values.decode(Int.self, forKey: .status)
        self.timestamp = try! values.decode(Int64.self, forKey: .timestamp)
        self.userid = try! values.decode(String.self, forKey: .userid)
        self.username = try! values.decode(String.self, forKey: .username)
        self.publickey = try! values.decode(String.self, forKey: .publickey)
        self.signature = try! values.decode(String.self, forKey: .signature)
        self.numcomments = try! values.decode(Int.self, forKey: .numcomments)
        self.version = try! values.decode(String.self, forKey: .version)
        self.publishedat = try! values.decode(Date.self, forKey: .publishedat)
        self.files = try! values.decode(Array<PFile>.self, forKey: .files)
        self.metadata = try! values.decode(Array<PoliteiaMetadata>.self, forKey: .metadata)
        self.votestatus = try values.decode(PVotestatus.self, forKey: .votestatus)
        self.votesummary = try! values.decode(PVotesummary.self, forKey: .votesummary)
        self.censorshiprecord = try! values.decode(PCensorShipRecord.self, forKey: .censorshiprecord)
    }
    
}

struct PoliteiaMetadata: Codable {
    var name: String
    var linkto: String
    var linkby: Int
    
    private enum CodingKeys : String, CodingKey {
        case name, linkto, linkby
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.name = try! values.decode(String.self, forKey: .name)
        self.linkto = try! values.decode(String.self, forKey: .linkto)
        self.linkby = try! values.decode(Int.self, forKey: .linkby)
    }
}

struct PCensorShipRecord: Codable {
    var token: String
    var merkle: String
    var signature: String
    
    private enum CodingKeys : String, CodingKey {
        case token, merkle, signature
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.token = try! values.decode(String.self, forKey: .token)
        self.merkle = try! values.decode(String.self, forKey: .merkle)
        self.signature = try! values.decode(String.self, forKey: .signature)
        
    }
}

struct PVotestatus: Codable {
    var token: String
    var status: PoliteiaVoteStatus
    var totalvotes: Int
    var optionsresult: Array<PVoteOptionResult>?
    var endheight: String
    var bestblock: String
    var numofeligiblevotes: Int
    var quorumpercentage: Int
    var passpercentage: Int
    var yesPercent: Float
    
    private enum CodingKeys: String, CodingKey {
        case token, status, totalvotes, passpercentage, optionsresult, endheight, bestblock, numofeligiblevotes, quorumpercentage
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.token = try! values.decode(String.self, forKey: .token)
        self.status = try! values.decode(PoliteiaVoteStatus.self, forKey: .status)
        self.totalvotes = try! values.decode(Int.self, forKey: .totalvotes)
        self.optionsresult = try values.decode(Array<PVoteOptionResult>?.self, forKey: .optionsresult)
        self.endheight = try! values.decode(String.self, forKey: .endheight)
        self.bestblock = try! values.decode(String.self, forKey: .bestblock)
        self.numofeligiblevotes = try! values.decode(Int.self, forKey: .numofeligiblevotes)
        self.quorumpercentage = try! values.decode(Int.self, forKey: .quorumpercentage)
        self.passpercentage = try! values.decode(Int.self, forKey: .passpercentage)
        
        let status = try! values.decode(PoliteiaVoteStatus.self, forKey: .status)
        if let voteResult = self.optionsresult, voteResult.count > 0 {
            let totalYes = Float(voteResult[1].votesreceived ?? 0)
            let totalNo = Float(voteResult[0].votesreceived ?? 0)
            let yesPercent = totalYes / (totalYes + totalNo) * 100.0
            if status == .FINISH {
                self.status = yesPercent >= Float(self.passpercentage) ? .APPROVED : .REJECT
            } else {
                self.status = status
            }
            self.yesPercent = yesPercent
        } else {
            self.status = status
            self.yesPercent = 0
        }
    }
}

struct PFile: Codable {
    var name: String
    var mime: String
    var digest: String
    var payload: String
    
    private enum CodingKeys: String, CodingKey {
        case name, mime, digest, payload
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.name = try! values.decode(String.self, forKey: .name)
        self.mime = try! values.decode(String.self, forKey: .mime)
        self.digest = try! values.decode(String.self, forKey: .digest)
        self.payload = try! values.decode(String.self, forKey: .payload)
    }
}

struct PVotesummary: Codable {
    var token: String
    var status: Int
    var eligibletickets: Int
    
    private enum CodingKeys: String, CodingKey {
        case token, status, eligibletickets
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.token = try! values.decode(String.self, forKey: .token)
        self.status = try! values.decode(Int.self, forKey: .status)
        self.eligibletickets = try! values.decode(Int.self, forKey: .eligibletickets)
    }
}

struct PVoteOptionResult: Codable {
    var option: POption
    var votesreceived: Int?
    
    private enum CodingKeys: String, CodingKey {
        case option, votesreceived
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.option = try! values.decode(POption.self, forKey: .option)
        self.votesreceived = try! values.decode(Int.self, forKey: .votesreceived)
    }
}

struct POption: Codable {
    var id: String
    var description: String
    var bits: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, description, bits
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.id = try! values.decode(String.self, forKey: .id)
        self.description = try! values.decode(String.self, forKey: .description)
        self.bits = try! values.decode(Int.self, forKey: .bits)
    }
}

enum PoliteiaCategory: Int32, CaseIterable {
    case all = 1
    case pre
    case active
    case approved
    case rejected
    case abandoned
}

extension PoliteiaCategory: CustomStringConvertible {
    var description: String {
        switch self {
        case .all:
            return "All"
        case .pre:
            return "In Discussion"
        case .active:
            return "Voting"
        case .approved:
            return "Approved"
        case .rejected:
            return "Rejected"
        case .abandoned:
            return "Abandoned"
        }
    }
}
