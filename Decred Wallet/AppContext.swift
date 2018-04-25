//
//  AppContext.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 19.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import Foundation
import Mobilewallet
class AppContext {
    public static let instance = AppContext()
    var storage: StorageProtocol?
    var walletManager: MobilewalletLibWallet?
}
