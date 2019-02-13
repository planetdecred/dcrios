//  AccountsData.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import Foundation
import UIKit

struct AccountsData {
    let color: UIColor?
    let spendableBalance: Double
    let title: String
    let totalBalance: Double
    var isExpanded: Bool = false
    
    init(entity: AccountsEntity, color: UIColor?) {
        self.color = color
        self.spendableBalance = Double((entity.Balance?.dcrSpendable)!)
        self.totalBalance = Double((entity.Balance?.dcrTotal)!)
        self.title = entity.Name
        self.isExpanded = false
    }
}

struct TransactionDetails {
    let title: String
    let value: NSAttributedString
    let textColor: UIColor?
}
