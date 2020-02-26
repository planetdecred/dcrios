//
//  Storyboard.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

enum Storyboard: String {
    case Main = "Main"
    case Security = "Security"
    case WalletSetup = "WalletSetup"
    case NavigationMenu = "NavigationMenu"
    case Overview = "Overview"
    case Receive = "Receive"
    case Send = "Send"
    case Transactions = "Transactions"
    case TransactionDetails = "TransactionDetails"
    case Wallets = "Wallets"
    case SeedBackup = "SeedBackup"
    case Settings = "Settings"
    case SecurityMenu = "SecurityMenu"
    case CustomDialogs = "CustomDialogs"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    func instantiateViewController<T: UIViewController>(for viewControllerType: T.Type, function: String = #function, line: Int = #line, file: String = #file) -> T {
        let storyboardID = (viewControllerType as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}
