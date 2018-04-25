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

    @IBOutlet weak var txSeed: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let seed = try? AppContext.instance.walletManager?.generateSeed()
        txSeed.text = seed ?? ""
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! SeedCheckupProtocol
        vc.seedToVerify = txSeed.text
    }

}
