//
//  Entities.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import Foundation
import RealmSwift

class WalletEntity : Object {
    @objc dynamic var id = ""
    @objc dynamic var seed = "" 
}

