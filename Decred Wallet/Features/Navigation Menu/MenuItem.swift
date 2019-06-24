//
//  MenuItems.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum MenuItem: String, CaseIterable {
    case overview = "Overview"
    case history = "History"
    case send = "Send"
    case receive = "Receive"
    case accounts = "Accounts"
    case security = "Security"
    case settings = "Settings"
    case help = "Help"
    
    // Each menu item's VC is wrapped in a navigation controller to enable the display of a navigation bar on each page,
    // and to allow each page perform VC navigations using `self.navigationController?.pushViewController`.
    var viewController: UIViewController {
        switch self {
        case .overview:
            return Storyboards.Overview.instantiateViewController(for: OverviewViewController.self).wrapInNavigationcontroller()
            
        case .history:
            return TransactionHistoryViewController(nibName: "TransactionHistoryViewController", bundle: nil).wrapInNavigationcontroller()
            
        case .send:
            return SendViewController.instance
            
        case .receive:
            return Storyboards.Main.instantiateViewController(for: ReceiveViewController.self).wrapInNavigationcontroller()
            
        case .accounts:
            return Storyboards.Main.instantiateViewController(for: AccountViewController.self).wrapInNavigationcontroller()
            
        case .security:
            return Storyboards.SecurityMenu.instantiateViewController(for: SecurityMenuViewController.self).wrapInNavigationcontroller()
            
        case .settings:
            return SettingsController.instantiate().wrapInNavigationcontroller()
            
        case .help:
            return Storyboards.Main.instantiateViewController(for: HelpViewController.self).wrapInNavigationcontroller()
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .overview:
            return UIImage(named: "overview")
            
        case .history:
            return UIImage(named: "history")
            
        case .send:
            return  UIImage(named: "send")
            
        case .receive:
            return UIImage(named: "receive")
            
        case .accounts:
            return UIImage(named: "menu-account")
            
        case .security:
            return UIImage(named: "security")
            
        case .settings:
            return UIImage(named: "settings")
            
        case .help:
            return UIImage(named: "help")
        }
    }
}
