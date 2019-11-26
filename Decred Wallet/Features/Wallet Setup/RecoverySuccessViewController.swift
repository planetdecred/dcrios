//
//  RecoverySuccessViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class RecoverySuccessViewController: UIViewController {
    
    @IBAction func getStarted(_ sender: Any) {
        NavigationMenuViewController.setupMenuAndLaunchApp(isNewWallet: true)
    }
}
