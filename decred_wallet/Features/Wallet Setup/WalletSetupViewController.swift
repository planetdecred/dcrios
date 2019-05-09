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
        
        var compileDate:Date{
            let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
            if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
                let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
                let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
            { return infoDate }
            return Date()
        }
    
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        let netType = infoForKey(GlobalConstants.Strings.NetType)! == "mainnet" ? "mainnet" : "testnet"
        build?.text = "build \(netType) " + dateformater.string(from: compileDate as Date)
    }
}
