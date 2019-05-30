//
//  Storyboards.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 09/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import UIKit

enum Storyboards: String {
    case Main = "Main"
    case WalletSetup = "WalletSetup"
    case Security = "Security"
    case NavigationMenu = "NavigationMenu"
    case Overview = "Overview"
    case Send = "Send"
    case Settings = "Settings"
    case TransactionFullDetailsViewController = "TransactionFullDetailsViewController"
    case SecurityMenu = "SecurityMenu"
    
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
