//
//  WalletSettings.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

class WalletSettings {
    let wallet: DcrlibwalletWallet
    
    init(for wallet: DcrlibwalletWallet) {
        self.wallet = wallet
    }
    
    func setBoolValue(_ value: Bool, for key: String) {
        self.wallet.setBoolConfigValueForKey(key, value: value)
    }
    
    func setStringValue(_ value: String, for key: String) {
        self.wallet.setStringConfigValueForKey(key, value: value)
    }
    
    func readBoolValue(for key: String, defaultValue: Bool = false) -> Bool {
        return self.wallet.readBoolConfigValue(forKey: key, defaultValue: defaultValue)
    }
    
    func readStringValue(for key: String, defaultValue: String = "") -> String {
        return self.wallet.readStringConfigValue(forKey: key, defaultValue: defaultValue)
    }
    
    /** Computed properties to access commonly used settings. */
    var useFingerprint: Bool {
        return self.readBoolValue(for: DcrlibwalletUseFingerprintConfigKey)
    }
    
    var txNotificationAlert: NotificationAlert {
        let selectedOption: String = self.readStringValue(for: DcrlibwalletIncomingTxNotificationsConfigKey)
        return NotificationAlert(rawValue: selectedOption) ?? .none
    }
}
