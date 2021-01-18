//
//  PeerInfo.swift
//  Decred Wallet
//
//  Created by JustinDo on 1/17/21.
//  Copyright © 2021 Decred. All rights reserved.
//

import Foundation

struct PeerInfo: Codable {
    var id: Int
    var addr: String
    var addrLocal: String
    var services: String
    var version: Int
    var subVer: String
    var startingHeight: Int64
    var banScore: Int
    
    private enum CodingKeys : String, CodingKey {
        case id, addr
        case addrLocal = "addr_local"
        case services
        case version
        case subVer = "sub_ver"
        case startingHeight = "starting_height"
        case banScore = "ban_score"
    }
    
    init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.id = try! values.decode(Int.self, forKey: .id)
        self.addr = try! values.decode(String.self, forKey: .addr)
        self.addrLocal = try! values.decode(String.self, forKey: .addrLocal)
        self.services = try! values.decode(String.self, forKey: .services)
        self.version = try! values.decode(Int.self, forKey: .version)
        self.subVer = try! values.decode(String.self, forKey: .subVer)
        self.startingHeight = try! values.decode(Int64.self, forKey: .startingHeight)
        self.version = try! values.decode(Int.self, forKey: .version)
        self.banScore = try! values.decode(Int.self, forKey: .banScore)
    }
}
