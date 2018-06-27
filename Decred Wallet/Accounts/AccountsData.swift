//  AccountsData.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import Foundation
import UIKit

struct AccountsData {
    let color: UIColor
    let spendableBalance: Double
    let title: String
    let totalBalance: Double
    var isExpanded: Bool = false
}

struct TransactionDetails {
    let title: String
    let value: String
    let textColor: UIColor
}
