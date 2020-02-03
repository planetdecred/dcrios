//
//  MenuItem.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum MenuItem: String, CaseIterable {
    case overview = "Overview"
    case transactions = "Transactions"
    case wallets = "Wallets"
    case more = "More"

    var viewController: UIViewController {
        switch self {
        case .overview:
            return OverviewViewController.instantiate(from: .Overview)
            
        case .transactions:
            return TransactionHistoryViewController.instantiate(from: .History)
        
        case .wallets:
            return WalletsViewController.instantiate(from: .Wallets)
        
        case .more:
            return SettingsController.instantiate(from: .Settings)
        }
    }

    var icon: UIImage? {
        switch self {
        case .overview:
            return  UIImage(named: "nav_menu/ic_overview")
        
        case .transactions:
            return  UIImage(named: "nav_menu/ic_transactions")
        
        case .wallets:
            return  UIImage(named: "nav_menu/ic_wallet")
        
        case .more:
            return  UIImage(named: "nav_menu/ic_menu")
        }
    }

    var displayTitle: String {
        return NSLocalizedString(self.rawValue.lowercased(), comment: "")
    }
}
