//
//  DecredAddressURI.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

struct DecredAddressURI {
    var address: String
    var amount: Double?
    
    init(uriString: String) {
        if uriString.contains("?") {
            let allParams = uriString.components(separatedBy: "?")
            self.address = allParams[0].replacingOccurrences(of: "decred:", with: "")
            
            let queryParams = allParams[1].components(separatedBy: "&")
            let amountString = queryParams.filter { $0.starts(with: "amount=") }.first
            self.amount = Double(amountString?.replacingOccurrences(of: "amount=", with: "") ?? "")
        } else {
            self.address = uriString.replacingOccurrences(of: "decred:", with: "") // only address is in string
        }
    }
}
