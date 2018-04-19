//
//  StorageProtocols.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 18.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import Foundation
import RealmSwift


protocol StorageBaseProtocol {
    var realm : Realm? { get }
}

extension StorageBaseProtocol{
    var realm : Realm? { get{ return try! Realm() } }
}

protocol StorageWalletProtocol {
    func isWalletCreated() -> Bool
}

extension StorageWalletProtocol {
    func isWalletCreated() -> Bool {
        return false
    }
}

protocol StorageProtocol: StorageBaseProtocol, StorageWalletProtocol {}

class Storage : StorageProtocol {}
