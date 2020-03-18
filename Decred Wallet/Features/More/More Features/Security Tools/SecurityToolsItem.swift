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
    
    // Each menu item's VC is wrapped in a navigation controller to enable the display of a navigation bar on each page,
    // and to allow each page perform VC navigations using `self.navigationController?.pushViewController`.
    var viewController: UIViewController {
        return ValidateAddressesViewController.instantiate(from: .ValidateAddresses)
    }
    
    var icon: UIImage? {
        return UIImage(named: "ic_location_pin")
    }
    
    var displayTitle: String {
        return  NSLocalizedString(self.rawValue, comment: "")
    }
}
