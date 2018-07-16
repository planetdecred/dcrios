//
//  WalletLogViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.
//

import UIKit

class WalletLogViewController: UIViewController {

    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallet Log"
        let testnetOn = UserDefaults.standard.bool(forKey: "pref_use_testnet")
        let logsType = testnetOn ? "testnet2" : "mainnet"
        load(log: logsType)
    }
    
    fileprivate func load(log:String){
        let logPath = NSHomeDirectory()+"/Documents/logs/\(log)/dcrwallet.log"
        let logContent = try? String(contentsOf: URL(fileURLWithPath: logPath))
        let aLogs = logContent?.split(separator: "\n")
        let cutOffLogFlow = aLogs?.suffix(from: (aLogs?.count)! - 500)
        logTextView.text = cutOffLogFlow?.joined(separator: ";\n")
    }
}
