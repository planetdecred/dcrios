//
//  WalletSetupViewController.swift
//  Decred Wallet

/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet

class WalletSetupViewController: WalletSetupBaseViewController {
    var seed: String! = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWalletRestore" {
            Settings.setValue(false, for: Settings.Keys.NewWalletSetUp)
        }
    }
    
    @IBAction func createNewwallet(_ sender: Any) {
        var generateSeedError: NSError?
        
        self.seed =  (DcrlibwalletGenerateSeed(&generateSeedError))
        if generateSeedError != nil {
            print("seed generate error: \(String(describing: generateSeedError?.localizedDescription))")
        } else {
            Settings.setValue(true, for: Settings.Keys.NewWalletSetUp)
            let securityVC = SecurityViewController.instantiate()
            securityVC.onUserEnteredPinOrPassword = { (pinOrPassword, securityType) in
                self.finalizeWalletSetup(self.seed, pinOrPassword, securityType)
            }
            self.navigationController?.pushViewController(securityVC, animated: true)
        }
    }
}
