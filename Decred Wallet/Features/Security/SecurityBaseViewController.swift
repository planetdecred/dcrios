//
//  SecurityBaseViewController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 09/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

class SecurityBaseViewController: UIViewController {
    static func instantiate() -> Self {
        return Storyboards.Security.instantiateViewController(for: self)
    }
}
