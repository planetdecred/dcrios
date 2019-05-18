//
//  WalletSetupViewController.swift
//  Decred Wallet

/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class WalletSetupViewController: WalletSetupBaseViewController {
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var restoreWallet: UILabel!
    @IBOutlet weak var createWallet: UILabel!
    @IBOutlet weak var build: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createWallet.text = "Create a New \n Wallet"
        restoreWallet.text = "Restore Existing \n Wallet"
        infoText.text = "Create or recover your wallet and \nstart managing your decred."
    
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        let netType = BuildConfig.IsTestNet ? "testnet" : BuildConfig.NetType
        build?.text = "build \(netType) " + dateformater.string(from: AppDelegate.compileDate)
    }
}
