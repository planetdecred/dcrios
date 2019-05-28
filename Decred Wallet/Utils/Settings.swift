//
//  Settings.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 21/05/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import Foundation

class Settings {
    struct Keys {
        static let IsStartupSecuritySet = "startup_security_set"
        static let StartupSecurityType = "startup_security_type"
        static let SpendingPassphraseSecurityType = "spending_security_type"
        
        static let SPVPeerIP = "pref_peer_ip"
        static let SyncOnCellular = "always_sync"
    }
    
    static func readValue<T>(for key: String) -> T {
        if T.self == Bool.self {
            return UserDefaults.standard.bool(forKey: key) as! T
        }
        return UserDefaults.standard.value(forKey: key) as! T
    }
    
    static func readOptionalValue<T>(for key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
    
    static func setValue(_ value: Any, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    /** Helper functions to read commonly used settings. */
    static func syncOnCellular() -> Bool {
        return Settings.readValue(for: Settings.Keys.SyncOnCellular)
    }
}
