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
    var name: String
    var state: Int
    var status: PoliteiaStatus
    var timestamp: Int64
    var userid: String
    var username: String
    var publickey: String
    var signature: String
    var numcomments: Int
    var version: String
    var publishedat: Date
    var files: Array<String>
    var metadata: Array<PoliteiaMetadata>
    var censorshiprecord: CensorShipRecord
    
    private enum CodingKeys : String, CodingKey {
        case name, state, status, timestamp, userid, username, publickey, signature, numcomments, version, publishedat, files, metadata, censorshiprecord
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.name = try! values.decode(String.self, forKey: .name)
        self.state = try! values.decode(Int.self, forKey: .state)
        self.status = try! values.decode(PoliteiaStatus.self, forKey: .status)
        self.timestamp = try! values.decode(Int64.self, forKey: .timestamp)
        self.userid = try! values.decode(String.self, forKey: .userid)
        self.username = try! values.decode(String.self, forKey: .username)
        self.publickey = try! values.decode(String.self, forKey: .publickey)
        self.signature = try! values.decode(String.self, forKey: .signature)
        self.numcomments = try! values.decode(Int.self, forKey: .numcomments)
        self.version = try! values.decode(String.self, forKey: .version)
        self.publishedat = try! values.decode(Date.self, forKey: .publishedat)
        self.files = try! values.decode(Array<String>.self, forKey: .files)
        self.metadata = try! values.decode(Array<PoliteiaMetadata>.self, forKey: .metadata)
        self.censorshiprecord = try! values.decode(CensorShipRecord.self, forKey: .censorshiprecord)
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

struct CensorShipRecord: Codable {
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

struct VoteStatus: Codable {
    var token: String
    var status: Int
    var totalvotes: Int
//    var optionsresult: Int
    var passpercentage: Int
    
    private enum CodingKeys: String, CodingKey {
        case token, status, totalvotes, passpercentage
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.token = try! values.decode(String.self, forKey: .token)
        self.status = try! values.decode(Int.self, forKey: .status)
        self.totalvotes = try! values.decode(Int.self, forKey: .totalvotes)
//        self.optionsresult = try! values.decode(Int.self, forKey: .optionsresult)
        self.passpercentage = try! values.decode(Int.self, forKey: .passpercentage)
    }
}

enum PoliteiaCategory: Int {
    case all = 1
    case pre
    case active
    case approved
    case rejected
    case abandoned
}
//AllProposals
//PreProposals
//ActiveProposals
//ApprovedProposals
//RejectedProposals
//AbandonedProposals

//struct OptionsResult: Codable {
//    var option:
//}


//"name":"Design of Social Media Memes for Decred",
//"state":2,
//"status":6,
//"timestamp":1597352889,
//"userid":"7602425c-d221-4154-aeb8-a7ddd2fa4649",
//"username":"cryptoarchitect",
//"publickey":"a57b21e8de3853a817cdaebdab9fe6d661d79434eb9528cd4f1431a3598b9931",
//"signature":"452d14d62fb58846751314c20c6023613174c6fee0e79c23cfe8c07546bc2dc681dd74ccbf7d46cabed8da9203dcb4e1dc4a42ebba8391e985bf37cf6646a407",
//"numcomments":23,
//"version":"2",
//"publishedat":1596194875,
//"files":[
//],
//"metadata":[
//{
//"name":"",
//"linkto":"",
//"linkby":0
//}
//],
//"censorshiprecord":{
//"token":"4f810317e07d134520faa6fd98a14b4c3e08c38227501558a90c1457c939ecd1",
//"merkle":"64f1c3b62724d11707a93fb1e1f0070d446b4e9b1e8d280f12d13f257ee26692",
//"signature":"0a0a52e7a2d96b19058cdbbc30c6786ecc1b8de506a512bafec4a05f20ee316aa3f88ef3b02c2ca8cf0e20ad07e4eadfd7e41cfa3e2d0fdf403388fdd80fb50d"
//}
//},
