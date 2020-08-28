//
//  Response.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/24/20.
//  Copyright © 2020 Decred. All rights reserved.
//

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
