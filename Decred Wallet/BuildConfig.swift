//
//  BuildConfig.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 18/05/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import Foundation

struct BuildConfig {
    #if IsTestnet
    static let IsTestNet = true
    static let TicketMaturity = 16
    static let NetType = "testnet3"
    #else
    static let IsTestNet = false
    static let TicketMaturity = 256
    static let NetType = "mainnet"
    #endif
}
