//
//  Settings.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

class Settings {
    static func setBoolValue(_ value: Bool, for key: String) {
        WalletLoader.shared.multiWallet.setBoolConfigValueForKey(key, value: value)
    }
    
    static func setIntValue(_ value: Int, for key: String) {
        WalletLoader.shared.multiWallet.setIntConfigValueForKey(key, value: value)
    }
    
    static func setInt32Value(_ value: Int32, for key: String) {
        WalletLoader.shared.multiWallet.setInt32ConfigValueForKey(key, value: value)
    }
    
    static func setInt64Value(_ value: Int64, for key: String) {
        WalletLoader.shared.multiWallet.setLongConfigValueForKey(key, value: value)
    }
    
    static func setDoubleValue(_ value: Double, for key: String) {
        WalletLoader.shared.multiWallet.setDoubleConfigValueForKey(key, value: value)
    }
    
    static func setStringValue(_ value: String, for key: String) {
        WalletLoader.shared.multiWallet.setStringConfigValueForKey(key, value: value)
    }
    
    static func readBoolValue(for key: String, defaultValue: Bool = false) -> Bool {
        return WalletLoader.shared.multiWallet.readBoolConfigValue(forKey: key, defaultValue: defaultValue)
    }
    
    static func readIntValue(for key: String, defaultValue: Int = 0) -> Int {
        return WalletLoader.shared.multiWallet.readIntConfigValue(forKey: key, defaultValue: defaultValue)
    }
    
    static func readInt32Value(for key: String, defaultValue: Int32 = 0) -> Int32 {
        return WalletLoader.shared.multiWallet.readInt32ConfigValue(forKey: key, defaultValue: defaultValue)
    }
    
    static func readInt64Value(for key: String, defaultValue: Int64 = 0) -> Int64 {
        return WalletLoader.shared.multiWallet.readLongConfigValue(forKey: key, defaultValue: defaultValue)
    }
    
    static func readDoubleValue(for key: String, defaultValue: Double = 0) -> Double {
        return WalletLoader.shared.multiWallet.readDoubleConfigValue(forKey: key, defaultValue: defaultValue)
    }
    
    static func readStringValue(for key: String) -> String {
        return WalletLoader.shared.multiWallet.readStringConfigValue(forKey: key)
    }
    
    static func clear() {
        WalletLoader.shared.multiWallet.clearConfig()
    }

    static func clearValue(for key: String) {
        WalletLoader.shared.multiWallet.deleteUserConfigValue(forKey: key)
    }
    
    /** Computed properties to access commonly used settings. */
    static var syncOnCellular: Bool {
        return Settings.readBoolValue(for: DcrlibwalletSyncOnCellularConfigKey)
    }
    
    static var spendUnconfirmed: Bool {
        return Settings.readBoolValue(for: DcrlibwalletSpendUnconfirmedConfigKey)
    }
    
    static var incomingNotificationEnabled: Bool {
        // todo, should be checked per wallet henceforth
        return true
    }
    
    static var currencyConversionOption: CurrencyConversionOption {
        let selectedOption: String = Settings.readStringValue(for: DcrlibwalletCurrencyConversionConfigKey)
        return CurrencyConversionOption(rawValue: selectedOption) ?? .None
    }
}
