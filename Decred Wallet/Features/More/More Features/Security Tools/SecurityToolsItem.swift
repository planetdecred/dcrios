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
    case verifyMessage = "verifyMessage"
    
    // Each menu item's VC is wrapped in a navigation controller to enable the display of a navigation bar on each page,
    // and to allow each page perform VC navigations using `self.navigationController?.pushViewController`.
    var viewController: UIViewController {
        switch self {
        case .validateAddresses:
            return ValidateAddressesViewController.instantiate(from: .ValidateAddresses)
        
        case .verifyMessage:
            return VerifyMessageViewController.instantiate(from: .VerifyMessage)
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .validateAddresses:
            return UIImage(named: "ic_location_pin")
            
        case .verifyMessage:
            return UIImage(named: "ic_verify_message")
        }
    }
    
    var displayTitle: String {
        return  NSLocalizedString(self.rawValue, comment: "")
    }
}
