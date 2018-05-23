//
//  AppContext.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import Foundation
import Mobilewallet
class AppContext {
    public static let instance = AppContext()
    var storage: StorageProtocol?
    var walletManager: MobilewalletLibWallet?
    var addressManager: MobilewalletTransactionCredit?
}
