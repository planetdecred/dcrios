//
//  MenuItem.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum MenuItem: String, CaseIterable {
    case overview = "Overview"
    case transactions = "Transactions"
    case wallets = "Wallets"
    case more = "More"
    
    // Each menu item's VC is wrapped in a navigation controller to enable the display of a navigation bar on each page
    // and to allow each page perform VC navigations using `self.navigationController?.pushViewController`.
    var viewController: UIViewController {
        switch self {
        case .overview:
            return Storyboards.Overview.instantiateViewController(for: OverviewViewController.self).wrapInNavigationcontroller()
            
        case .transactions:
            return TransactionHistoryViewController(nibName: "TransactionHistoryViewController", bundle: nil).wrapInNavigationcontroller()
        
        case .wallets:
            return Storyboards.Main.instantiateViewController(for: AccountViewController.self).wrapInNavigationcontroller()
        
        case .more:
            return Storyboards.Overview.instantiateViewController(for: SettingsController.self).wrapInNavigationcontroller() // TODO: Change to correct "more" controller.
        }
    }
    
    var icon: UIImage? {
        switch self {
            case .overview:
                return UIImage(named: "nav_menu/ic_overview")
            
            case .transactions:
                return UIImage(named: "nav_menu/ic_transactions")
            
            case .wallets:
                return UIImage(named: "nav_menu/ic_wallet")
            
            case .more:
                return  UIImage(named: "nav_menu/ic_menu")
        }
    }

    var displayTitle: String {
        return NSLocalizedString(self.rawValue.lowercased(), comment: "")
    }
}
