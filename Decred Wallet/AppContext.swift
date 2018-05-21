//
//  AppContext.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import Foundation
import Wallet
class AppContext {
    public static let instance = AppContext()
    var walletManager: WalletLibWallet?
}
