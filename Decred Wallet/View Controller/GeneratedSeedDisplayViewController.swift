//
//  GeneratedSeedDisplayViewController.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 25.04.18.
//  Copyright © 2018 Macsleven. All rights reserved.
//

import UIKit
import Mobilewallet

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
