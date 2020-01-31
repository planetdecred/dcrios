//
//  SingleToMultiWalletMigration.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SingleToMultiWalletMigration {
    static var migrationNeeded: Bool {
        return WalletLoader.shared.multiWallet.v1WalletExists()
    }
    
    // Requires startup passphrase (aka wallet public passphrase) to
    // disable public passphrase security on the wallet after migrating.
    // The startup passphrase will continue to be used as the app's startup passphrase.
    static func migrateExistingWallet() {
        if !PreMultiWalletSettings.readValue(for: .IsStartupSecuritySet) {
            SingleToMultiWalletMigration.self.migrate(startupPinOrPassword: "", completion: nil)
            return
        }
        
        var securityRequestVC: SecurityCodeRequestBaseViewController
        var startupSecurityType: String
        
        if PreMultiWalletSettings.readValue(for: .StartupSecurityType) == SecurityType.password.rawValue {
            securityRequestVC = RequestPasswordViewController.instantiate(from: .Security)
            startupSecurityType = SecurityType.password.localizedString
        } else {
            securityRequestVC = RequestPinViewController.instantiate(from: .Security)
            startupSecurityType = SecurityType.pin.localizedString
        }
        
        securityRequestVC.request = Security.Request(for: .Startup)
        securityRequestVC.request.prompt = String(format: LocalizedStrings.unlockWithStartupCode, startupSecurityType)
        securityRequestVC.request.submitBtnText = LocalizedStrings.unlock
        securityRequestVC.request.showCancelButton = false
        
        securityRequestVC.callbacks.onSecurityCodeEntered = SingleToMultiWalletMigration.self.migrate
        
        securityRequestVC.modalPresentationStyle = .pageSheet
        AppDelegate.shared.window?.rootViewController?.present(securityRequestVC, animated: true)
    }
    
    private static func migrate(startupPinOrPassword: String,
                                securityType: SecurityType? = nil,
                                completion: SecurityCodeRequestCompletionDelegate?) {
        
        var privatePassphraseType = DcrlibwalletPassphraseTypePass
        if PreMultiWalletSettings.readValue(for: .SpendingPassphraseSecurityType) == SecurityType.password.rawValue {
            privatePassphraseType = DcrlibwalletPassphraseTypePin
        }
        
        var startupSecurityType = DcrlibwalletPassphraseTypePass
        if securityType == .pin {
            startupSecurityType = DcrlibwalletPassphraseTypePin
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.migrateV1Wallet(startupPinOrPassword,
                                                                    originalPrivatePassType: privatePassphraseType)
                
                // attempt to re-set the app startup passphrase
                if startupPinOrPassword != "" {
                    try? WalletLoader.shared.multiWallet.setStartupPassphrase(startupPinOrPassword.utf8Bits,
                                                                              passphraseType: startupSecurityType)
                }
                
                PreMultiWalletSettings.migrateUserConfig()
                
                DispatchQueue.main.async {
                    completion?.securityCodeProcessed()
                    NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
                }
                
            } catch let error {
                print("link existing wallet error: \(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        completion?.securityCodeError(errorMessage: StartupPinOrPassword.invalidSecurityCodeMessage())
                    } else {
                        completion?.securityCodeError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
}

// PreMultiWalletSettings retained for use in migrating user preferences
// to the new multiwallet config feature.
fileprivate struct PreMultiWalletSettings {
    enum Key: String {
        // These are now saved directly by multiwallet when setting a startup passphrase.
        case IsStartupSecuritySet = "startup_security_set"
        case StartupSecurityType = "startup_security_type"
        
        // This is saved by multiwallet in the call to `multiWallet.migrateV1Wallet()`.
        case SpendingPassphraseSecurityType = "spending_security_type"
        
        case SPVPeerIP = "pref_peer_ip"
        case SyncOnCellular = "always_sync"
        
        case SpendUnconfirmed = "pref_spend_unconfirmed"
        case IncomingNotification = "pref_notification_switch"
        case CurrencyConversionOption = "currency_conversion_option"
        case NetworkMode = "network_mode"
        
        case LastTxHash = "last_tx_hash"
    }
    
    static func readValue<T>(for key: Key) -> T {
        if T.self == Bool.self {
            return UserDefaults.standard.bool(forKey: key.rawValue) as! T
        }
        return UserDefaults.standard.value(forKey: key.rawValue) as! T
    }
    
    static func readOptionalValue<T>(for key: Key) -> T? {
        if T.self == Bool.self {
            return UserDefaults.standard.bool(forKey: key.rawValue) as? T
        }
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    
    static func migrateUserConfig() {
        if let spvPeerIP: String = readOptionalValue(for: .SPVPeerIP) {
            Settings.setStringValue(spvPeerIP, for: DcrlibwalletSpvPersistentPeerAddressesConfigKey)
        }
        
        if let syncOnCellular: Bool = readValue(for: .SyncOnCellular) {
            Settings.setBoolValue(syncOnCellular, for: DcrlibwalletSyncOnCellularConfigKey)
        }
        
        if let spendUnconfirmed: Bool = readValue(for: .SpendUnconfirmed) {
            Settings.setBoolValue(spendUnconfirmed, for: DcrlibwalletSpendUnconfirmedConfigKey)
        }
        
        if let incomingNotificationEnabled: Bool = readValue(for: .IncomingNotification) {
            // todo update these notification statuses when implementing wallets page -> wallet settings.
            let notificationStatus = incomingNotificationEnabled ? "vibration" : "off"
            WalletLoader.shared.wallets.forEach({
                try? WalletLoader.shared.multiWallet
                    .updateIncomingNotificationsUserPreference($0.id_, notificationsPref: notificationStatus)
            })
        }
        
        if let currencyConversionOption: String = readOptionalValue(for: .CurrencyConversionOption) {
            Settings.setStringValue(currencyConversionOption, for: DcrlibwalletCurrencyConversionConfigKey)
        }
        
        if let networkMode: Int = readOptionalValue(for: .NetworkMode) {
            Settings.setIntValue(networkMode, for: DcrlibwalletNetworkModeConfigKey)
        }
        
        if let lastTxHash: String = readOptionalValue(for: .LastTxHash) {
            Settings.setStringValue(lastTxHash, for: DcrlibwalletLastTxHashConfigKey)
        }
        
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}
