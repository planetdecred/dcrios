//
//  SeedBackupSuccessViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SeedBackupSuccessViewController: UIViewController {
    var delegate: SeedBackupModalHandler?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onBackToOverview(_ sender: Any) {
        self.delegate?.updateSeedBackupSectionViewVisibility()
        navigateToBackScreen()
    }
}
