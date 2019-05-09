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
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    func instantiateViewController<T: UIViewController>(vc: T.Type, function: String = #function, line: Int = #line, file: String = #file) -> T {
        let storyboardID = (vc as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    // Not using static so that individual VCs can override to provide custom storyboardID value.
    // By default, this returns the name of VC class as the storyboard ID.
    class var storyboardID: String {
        return "\(self)"
    }
}
