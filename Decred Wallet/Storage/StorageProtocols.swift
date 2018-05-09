//
//  StorageProtocols.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
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
