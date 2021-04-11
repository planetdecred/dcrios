//
//  Response.swift
//  Decred Wallet
//
// Copyright © 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

struct Response<T: Codable>: Codable {
    var result: T?
    var error: String
    
    private enum CodingKeys: String, CodingKey {
        case result, error
    }
    
     init(from decoder: Decoder) throws {
        let values = try! decoder.container(keyedBy: CodingKeys.self)
        self.result = try values.decode(T?.self, forKey: .result)
        self.error = (try values.decode(String?.self, forKey: .error)) ?? ""
    }
}
