//
//  BuildConfig.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

struct BuildConfig {
    #if IsTestnet
    static let IsTestNet = true
    static let TicketMaturity = 16
    static let NetType = "testnet3"
    static let PoliteiaHost = DcrlibwalletPoliteiaTestnetHost
    #else
    static let IsTestNet = false
    static let TicketMaturity = 256
    static let NetType = "mainnet"
    static let PoliteiaHost = DcrlibwalletPoliteiaMainnetHost
    #endif
}
