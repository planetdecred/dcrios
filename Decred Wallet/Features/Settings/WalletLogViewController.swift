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
        self.removeNavigationBarItem()
        self.navigationItem.title = "Wallet Log"
        self.progressHud = Utils.showProgressHud(withText: "Loading log...")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Copy", style: .plain, target: self, action: #selector(copyLog))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logTextView.text = readLog()
    }
    
    @objc func copyLog() -> Void {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.logTextView.text
            self.showOkAlert(message: "Wallet log copied")
        }
    }
    
    private func readLog() -> String {
        do {
            let logPath = "\(WalletLoader.appDataDir)/\(BuildConfig.NetType)/dcrlibwallet.log"
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
