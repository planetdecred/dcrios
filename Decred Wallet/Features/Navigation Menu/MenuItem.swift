//
//  MenuItems.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 11/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

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
            return Storyboards.Main.instantiateViewController(for: SendViewController.self).wrapInNavigationcontroller()
            
        case .receive:
            return Storyboards.Main.instantiateViewController(for: ReceiveViewController.self).wrapInNavigationcontroller()
            
        case .accounts:
            return Storyboards.Main.instantiateViewController(for: AccountViewController.self).wrapInNavigationcontroller()
            
        case .security:
            return Storyboards.Main.instantiateViewController(for: SecurityMenuViewController.self).wrapInNavigationcontroller()
            
        case .settings:
            return Storyboards.Main.instantiateViewController(for: SettingsController.self).wrapInNavigationcontroller()
            
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
