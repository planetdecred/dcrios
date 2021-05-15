//
//  MoreMenuItem.swift
//  Decred Wallet
//
// Copyright (c)2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum MoreMenuItem: String, CaseIterable {
    case settings = "settings"
    case securityTools = "securityTools"
    case politeia = "politeia"
    case help = "help"
    case about = "about"
    case debug = "debug"
    
    // Each menu item's VC is wrapped in a navigation controller to enable the display of a navigation bar on each page,
    // and to allow each page perform VC navigations using `self.navigationController?.pushViewController`.
    var viewController: UIViewController {
        switch self {
        case .settings:
            return SettingsController.instantiate(from: .Settings)
            
        case .securityTools:
            return SecurityToolsViewController.instantiate(from: .SecurityTools)
            
        case .politeia:
            return PoliteiaController.instantiate(from: .Politeia)
            
        case .help:
            return HelpTableViewController.instantiate(from: .Help)
            
        case .about:
            return AboutTableViewController.instantiate(from: .About)
            
        case.debug:
            return DebugTableViewController.instantiate(from: .Debug)
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .settings:
            return UIImage(named: "settings")
            
        case .securityTools:
            return UIImage(named: "security_tools")
            
        case .politeia:
            return UIImage(named: "ic_politeia")
            
        case .help:
            return UIImage(named: "help")
            
        case .about:
            return UIImage(named: "info")
            
        case .debug:
            return UIImage(named: "debug")
        }
    }
    
    var displayTitle: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
