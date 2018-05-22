//
//  GeneratedSeedDisplayViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit
import Wallet

class GeneratedSeedDisplayViewController: UIViewController {

    @IBOutlet weak var vWarningIcon: UIView!
    @IBOutlet weak var txSeed: UITextView!
    @IBOutlet weak var vWarningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let seed = try? AppContext.instance.walletManager?.generateSeed()
        txSeed.text = seed ?? ""
        vWarningLabel.layer.borderColor = UIColor(hex: "fd714a").cgColor
        vWarningIcon.layer.borderColor = UIColor(hex: "fd714a").cgColor
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = txSeed.text
    }

}
