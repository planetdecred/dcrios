//
//  Utils.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import Foundation

extension Notification.Name {
    static let NeedAuth =   Notification.Name("NeedAuthorize")
    static let NeedLogout = Notification.Name("NeedDeauthorize")
}

func isWalletCreated() -> Bool{
        let fm = FileManager()
        do{
            let contents = try fm.contentsOfDirectory(atPath: NSHomeDirectory()+"/Documents/testnet2")
            let result = contents.count > 0
            return result
        }catch{
            return false
    }
}
