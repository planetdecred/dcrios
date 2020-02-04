//
//  RecoverySuccessViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class RestoreExistingWalletSuccessViewController: UIViewController {
    @IBAction func getStarted(_ sender: Any) {
        NavigationMenuTabBarController.setupMenuAndLaunchApp(isNewWallet: false)
    }
}
