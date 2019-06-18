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
        static let DefaultWallet = "default_wallet"
        static let HiddenWalletPrefix = "hidden"
        static let newWalletSetUp = "new_wallet_set_up"
        
        static let SPVPeerIP = "pref_peer_ip"
        static let RemoteServerIP = "pref_server_ip"
        static let SyncOnCellular = "always_sync"
        
        static let SpendUnconfirmed = "pref_spend_unconfirmed"
        static let IncomingNotification = "pref_notification_switch"
        static let CurrencyConversionOption = "currency_conversion_option"
        static let NetworkMode = "network_mode"
        
        static let LastTxHash = "last_tx_hash"
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
    
    static func clear() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    static func clearValue(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    /** Computed properties to access commonly used settings. */
    static var syncOnCellular: Bool {
        return Settings.readValue(for: Settings.Keys.SyncOnCellular)
    }
    
    static var spendUnconfirmed: Bool {
        return Settings.readValue(for: Settings.Keys.SpendUnconfirmed)
    }
    
    static var incomingNotificationEnabled: Bool {
        return Settings.readValue(for: Settings.Keys.IncomingNotification)
    }
    
    static var currencyConversionOption: CurrencyConversionOption {
        let selectedOption: String = Settings.readOptionalValue(for: Settings.Keys.CurrencyConversionOption) ?? ""
        return CurrencyConversionOption(rawValue: selectedOption) ?? .None
    }
    
    static var networkMode: Int {
        return Settings.readOptionalValue(for: Settings.Keys.NetworkMode) ?? 0
    }
}
