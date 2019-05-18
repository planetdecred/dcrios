//
//  WalletLogViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import JGProgressHUD

class WalletLogViewController: UIViewController {
    @IBOutlet weak var logTextView: UITextView!
    var progressHud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Wallet Log"
        self.progressHud = Utils.showProgressHud(withText: "Loading log...")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logTextView.text = readLog()
    }
    
    private func readLog() -> String {
        let netType = Utils.infoForKey(GlobalConstants.Strings.NetType)!
        let logPath = NSHomeDirectory()+"/Documents/dcrlibwallet/\(netType)/dcrlibwallet.log"
        
        do {
            let logContent = try String(contentsOf: URL(fileURLWithPath: logPath))
            let logEntries = logContent.split(separator: "\n")
            if logEntries.count > 500 {
                self.progressHud.dismiss()
                return logEntries.suffix(from: logEntries.count - 500).joined(separator: ";\n")
            } else {
                self.progressHud.dismiss()
                return logEntries.suffix(from: 0).joined(separator: ";\n")
            }
        } catch (let error) {
            self.progressHud.dismiss()
            return "Error loading log: \(error.localizedDescription)"
        }
    }
}
