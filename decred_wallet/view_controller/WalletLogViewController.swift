//
//  WalletLogViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class WalletLogViewController: UIViewController {
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallet Log"
         let progressHud = Utils.showProgressHud(withText: "Loading log...")
        self.logTextView.text = WalletLogViewController.readLog()
        progressHud.dismiss()
    }
    
    private static func readLog() -> String {
        let netType = Utils.infoForKey(GlobalConstants.Strings.NetType)!
        let logPath = NSHomeDirectory()+"/Documents/dcrlibwallet/\(netType)/dcrlibwallet.log"
        
        do {
            let logContent = try String(contentsOf: URL(fileURLWithPath: logPath))
            let logEntries = logContent.split(separator: "\n")
            if logEntries.count > 500 {
                return logEntries.suffix(from: logEntries.count - 500).joined(separator: ";\n")
            } else {
                return logEntries.suffix(from: 0).joined(separator: ";\n")
            }
        } catch (let error) {
            return "Error loading log: \(error.localizedDescription)"
        }
    }
}
