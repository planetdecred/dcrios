//
//  PoliteiaItem.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/27/20.
//  Copyright © 2020 Decred. All rights reserved.
//

import UIKit

enum PoliteiaItem: String, CaseIterable {
    case politeiaDetail = "politeiaDetail"
    
    // Each menu item's VC is wrapped in a navigation controller to enable the display of a navigation bar on each page,
    // and to allow each page perform VC navigations using `self.navigationController?.pushViewController`.
    var viewController: UIViewController {
        switch self {
        case .politeiaDetail:
            return ValidateAddressesViewController.instantiate(from: .PoliteiaDetail)
        }
    }
    
    var displayTitle: String {
        return  NSLocalizedString(self.rawValue, comment: "")
    }
}
