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
        static let DEFAULT = "default"
        static let MIXED = "mixed"
        static let UNMIXED = "unmixed"
        static let SHOWN_PRIVACY_TOOLTIP = "shown_privacy_tooltip"
        static let PROPOSAL_ID = "proposalId"
        static let HAS_SETUP_PRIVACY = "has_setup_privacy"
        static let BADGER = "badgerdb"
        static let BDB = "bdb"
        static let COLORTHEME = "color_theme"
        static let SHOW_HIDE_BALANCE = "shown_hide_balance"
        static let HAS_SHOW_POLITEIA_WELCOME = "has_show_politeia_welcome"
        static let GOVERNANCE_SETTING = "governance_setting"
        static let BIOMATRIC_AUTHEN = "biomatric_authen_%d"
    }
    
    struct Wallet {
        static let defaultRequiredConfirmations: Int32 = 2
        static let DEFAULT_ACCOUNT_NUMBER = 0
    }
}
