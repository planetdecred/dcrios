//  AccountsData.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

struct AccountsData {
    let color: UIColor?
    let spendableBalance: NSDecimalNumber
    let title: String
    let totalBalance: Double
    var isExpanded: Bool = false
    let number: Int32
    
    init(entity: AccountsEntity, color: UIColor?) {
        self.color = color
        self.spendableBalance = (spendable(account: entity) as NSDecimalNumber).round(8)
        self.totalBalance = Double((entity.Balance?.dcrTotal)!)
        self.title = entity.Name
        self.number = entity.Number
        self.isExpanded = false
    }
}

struct TransactionDetails {
    let title: String
    let value: NSAttributedString
    let textColor: UIColor?
}
