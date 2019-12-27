//
//  SecurityToolsItem.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum SecurityToolsItem: String, CaseIterable {
    case validateAddresses = "validateAddresses"
    case signMessage = "signMessage"
    case verifyMessage = "verifyMessage"
    
    // Each menu item's VC is wrapped in a navigation controller to enable the display of a navigation bar on each page,
    // and to allow each page perform VC navigations using `self.navigationController?.pushViewController`.
    var viewController: UIViewController {
        switch self {
        case .validateAddresses:
            return Storyboards.ValidateAddresses.instantiateViewController(for: ValidateAddressesViewController.self)
            
        case .signMessage: break
            //return Storyboards.SignMessage.instantiateViewController(for: SignMessageViewController.self)
            
        case .verifyMessage: break
           // return Storyboards.VerifyMessage.instantiateViewController(for: VerifyMessageViewController.self)
        }
        return UIViewController()
    }
    
    var icon: UIImage? {
        switch self {
        case .validateAddresses:
            return UIImage(named: "ic_location_pin")
            
        case .signMessage:
            return UIImage(named: "ic_sign")
            
        case .verifyMessage:
            return UIImage(named: "ic_verify")
        }
    }
    
    var displayTitle: String {
        return  NSLocalizedString(self.rawValue, comment: "")
    }
}
