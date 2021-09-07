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
            return TransactionsViewController.instantiate(from: .Transactions)
        
        case .wallets:
            return WalletsViewController.instantiate(from: .Wallets)
        
        case .more:
            return MoreMenuViewController.instantiate(from: .More).wrapInNavigationcontroller()
        }
    }
    
    var isActive: Bool {
        switch self {
        case .overview:
            return true
            
        case .transactions:
            return true
        
        case .wallets:
            return true
        
        case .more:
            return true
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .overview:
            return UIImage(named: "nav_menu/ic_overview")
        
        case .transactions:
            return UIImage(named: "nav_menu/ic_transactions")
        
        case .wallets:
            return UIImage(named: "nav_menu/ic_wallet_inactive")
        
        case .more:
            return UIImage(named: "nav_menu/ic_menu_inactive")
        }
    }
    
    var iconDarkTheme: UIImage? {
        switch self {
        case .overview:
            return UIImage(named: "nav_menu/ic_overview_inactive")
        
        case .transactions:
            return UIImage(named: "nav_menu/ic_transactions_inactive")
        
        case .wallets:
            return  UIImage(named: "nav_menu/ic_wallet_inactive")
        
        case .more:
            return  UIImage(named: "nav_menu/ic_menu_inactive")
        }
    }

    var displayTitle: String {
        return NSLocalizedString(self.rawValue.lowercased(), comment: "")
    }
}
