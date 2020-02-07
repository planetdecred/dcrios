//
//  Wallet.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet

class Wallet: NSObject {
    private(set) var id: Int
    private(set) var name: String
    private(set) var balance: String
    private(set) var accounts = [DcrlibwalletAccount]()
    private(set) var isSeedBackedUp: Bool = false
    private(set) var displayAccounts: Bool = false
    
    init(_ wallet: DcrlibwalletWallet, accountsFilterFn: ((DcrlibwalletAccount) -> Bool)? = nil) {
        self.id = wallet.id_
        self.name = wallet.name
        self.balance = "\((Decimal(wallet.totalWalletBalance()) as NSDecimalNumber).round(8)) DCR"
        self.accounts = wallet.accounts(confirmations: 0)
        self.visibleAccounts = self.accounts.filter({!$0.isHidden && $0.number != INT_MAX })
        self.isSeedBackedUp = wallet.seed.isEmpty
        self.displayAccounts = false

        if accountsFilterFn == nil {
            self.accounts = wallet.accounts(confirmations: 0)
        } else {
            self.accounts = wallet.accounts(confirmations: 0).filter(accountsFilterFn!)
        }
    }
    
    func toggleAccountsDisplay() {
        self.displayAccounts = !self.displayAccounts
    }

    func reloadAccounts() {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: self.id) else {
            return
        }
        self.accounts = wallet.accounts(confirmations: 0)
    }
}
