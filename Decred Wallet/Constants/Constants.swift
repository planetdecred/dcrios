//
//  Constants.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

struct GlobalConstants {    
    struct Strings {
        static let VOTE = "VOTE"
        static let REVOCATION = "REVOCATION"
        static let TICKET_PURCHASE = "TICKET_PURCHASE"
        static let COINBASE = "COINBASE"
        static let REGULAR = "REGULAR"
        static let TESTNET_HD_PATH = "m / 44' / 1' /"
        static let LEGACY_TESTNET_HD_PATH = "m / 44' / 11' /"
        static let MAINNET_HD_PATH = "m / 44' / 42' /"
        static let LEGACY_MAINNET_HD_PATH = "m / 44' / 20' /"
    }
    
    struct Wallet {
        static let defaultRequiredConfirmations: Int32 = 2
    }
}
