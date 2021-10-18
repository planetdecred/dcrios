//
//  SettingNavigationViewController.swift
//  Decred Wallet
//
//  Created by dnvinh on 28/09/2021.
//  Copyright © 2021 Decred. All rights reserved.
//

import Foundation
import UIKit

class SettingNavigationViewController: UINavigationController {
    override func viewWillDisappear(_ animated: Bool) {
        if self.isModal {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
