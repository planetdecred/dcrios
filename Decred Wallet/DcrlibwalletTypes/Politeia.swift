//
//  Politeia.swift
//  Decred Wallet
//
// Copyright © 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

struct Politeia: Codable {
    var ID: Int
    var token: String
    var category: Int32
    var name: String
    var state: Int32
    var status: Int32
    var timestamp: Int64
    var userid: String
    var username: String
    var numcomments: Int32
    var version: String
    var publishedat: Date
    var indexfile: String
    var fileversion: String
    var votestatus: PoliteiaVoteStatus
    var voteapproved: Bool
    var yesvotes: Int32
    var novotes: Int32
    var eligibletickets: Int32
    var quorumpercentage: Int32
    var passpercentage: Int32?
    var yesPercent: Float
    
    private enum CodingKeys : String, CodingKey {
        case ID, token, category, name, state, status, timestamp, userid, username, numcomments, version, publishedat, indexfile, fileversion, votestatus, voteapproved, yesvotes, novotes, eligibletickets, quorumpercentage, passpercentage
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.ID = try! values.decode(Int.self, forKey: .ID)
        self.token = try! values.decode(String.self, forKey: .token)
        self.category = try! values.decode(Int32.self, forKey: .category)
        self.name = try! values.decode(String.self, forKey: .name)
        self.state = try! values.decode(Int32.self, forKey: .state)
        self.timestamp = try! values.decode(Int64.self, forKey: .timestamp)
        self.userid = try! values.decode(String.self, forKey: .userid)
        self.username = try! values.decode(String.self, forKey: .username)
        self.numcomments = try! values.decode(Int32.self, forKey: .numcomments)
        self.version = try! values.decode(String.self, forKey: .version)
        self.publishedat = try! values.decode(Date.self, forKey: .publishedat)
        self.indexfile = try! values.decode(String.self, forKey: .indexfile)
        self.fileversion = try! values.decode(String.self, forKey: .fileversion)
        self.status = try! values.decode(Int32.self, forKey: .status)
        self.voteapproved = try! values.decode(Bool.self, forKey: .voteapproved)
        self.yesvotes = try! values.decode(Int32.self, forKey: .yesvotes)
        self.novotes = try! values.decode(Int32.self, forKey: .novotes)
        self.eligibletickets = try! values.decode(Int32.self, forKey: .eligibletickets)
        self.quorumpercentage = try! values.decode(Int32.self, forKey: .quorumpercentage)
        self.passpercentage = try? values.decode(Int32.self, forKey: .passpercentage)
        let voteStatus = try! values.decode(PoliteiaVoteStatus.self, forKey: .votestatus)
        let yesPercent = self.yesvotes > 0 ? Float(self.yesvotes) / Float(self.yesvotes + self.novotes) * 100.0 : 0
        self.yesPercent = yesPercent
        if let passPercent = self.passpercentage, voteStatus == .FINISH {
            let quorum = Float(self.eligibletickets) * (Float(self.quorumpercentage) / 100)
            let approved = self.yesvotes >= Int32(quorum * (Float(passPercent) / 100)) && yesPercent >= Float(passPercent)
            self.votestatus = approved ? .APPROVED : .REJECT
        } else if status == 6 {
            self.votestatus = .ABANDONED
        } else {
            self.votestatus = voteStatus
        }
    }
    
    init(_ proposal: DcrlibwalletProposal) {
        self.ID = proposal.id_
        self.token = proposal.token
        self.category = proposal.category
        self.name = proposal.name
        self.state = proposal.state
        self.timestamp = proposal.timestamp
        self.userid = proposal.userID
        self.username = proposal.username
        self.numcomments = proposal.numComments
        self.version = proposal.version
        self.publishedat = Date(milliseconds: Int(proposal.publishedAt))
        self.indexfile = proposal.indexFile
        self.fileversion = proposal.indexFileVersion
        self.status = proposal.status
        self.voteapproved = proposal.voteApproved
        self.yesvotes = proposal.yesVotes
        self.novotes = proposal.noVotes
        self.eligibletickets = proposal.eligibleTickets
        self.quorumpercentage = proposal.quorumPercentage
        self.passpercentage = proposal.passPercentage
        let voteStatus = PoliteiaVoteStatus(rawValue: Int(proposal.voteStatus))!
        let yesPercent = self.yesvotes > 0 ? Float(self.yesvotes) / Float(self.yesvotes + self.novotes) * 100.0 : 0
        self.yesPercent = yesPercent
        if let passPercent = self.passpercentage, voteStatus == .FINISH {
            let quorum = Float(self.eligibletickets) * (Float(self.quorumpercentage) / 100)
            let approved = self.yesvotes >= Int32(quorum * (Float(passPercent) / 100)) && yesPercent >= Float(passPercent)
            self.votestatus = approved ? .APPROVED : .REJECT
        } else if status == 6 {
            self.votestatus = .ABANDONED
        } else {
            self.votestatus = voteStatus
        }
    }
}

enum PoliteiaCategory: Int32, CaseIterable {
    case pre = 2
    case active
    case approved
    case rejected
    case abandoned
}

extension PoliteiaCategory: CustomStringConvertible {
    var description: String {
        switch self {
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
