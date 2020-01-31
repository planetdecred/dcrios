//
//  AccountsData.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

struct AccountHeader {
    let color: UIColor?
    let spendableBalance: NSDecimalNumber
    let title: String
    let totalBalance: Double
    var isExpanded: Bool = false
    let number: Int32
    
    init(entity: DcrlibwalletAccount, color: UIColor?) {
        self.color = color
        self.spendableBalance = (Utils.spendable(account: entity) as NSDecimalNumber).round(8)
        self.totalBalance = Double((entity.balance?.dcrTotal)!)
        self.title = entity.name
        self.number = entity.number
        self.isExpanded = false
    }
    
    var isHidden: Bool {
        // deprecated feature
        return false
    }
}

struct TransactionDetails {
    let title: String
    let value: NSAttributedString
    let textColor: UIColor?
}
