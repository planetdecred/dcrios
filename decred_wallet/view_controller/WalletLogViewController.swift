//
//  WalletLogViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit
import os

class WalletLogViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallet Log"
        let testnetOn = UserDefaults.standard.bool(forKey: "pref_use_testnet")
        let logsType = testnetOn ? "testnet3" : "mainnet"
        load(log: logsType)
    }
    
    fileprivate func load(log:String){
        let logPath = NSHomeDirectory()+"/Documents/dcrwallet/logs/\(log)/dcrwallet.log"
        let logContent = try? String(contentsOf: URL(fileURLWithPath: logPath))
        let aLogs = logContent?.split(separator: "\n")
        var cutOffLogFlow = aLogs?.suffix(from: 0)
        if (aLogs?.count)! > 500 {
            cutOffLogFlow = aLogs?.suffix(from: (aLogs?.count)! - 500)
        }
        
        logTextView.text = cutOffLogFlow?.joined(separator: ";\n")
    }
}
