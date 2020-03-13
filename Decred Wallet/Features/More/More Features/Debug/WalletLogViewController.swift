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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
            self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
        
            //setup leftBar button
            self.addNavigationBackButton()
            let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.walletLog, style: .plain, target: self, action: nil)
            barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
            
            self.navigationItem.leftBarButtonItems =  [ (self.navigationItem.leftBarButtonItem)!, barButtonTitle]
            
            self.progressHud = Utils.showProgressHud(withText: LocalizedStrings.loading)
            
            //setup rightBar button
            let infoBtn = UIButton(type: .custom)
            infoBtn.setImage(UIImage(named: "ic_paste"), for: .normal)
            infoBtn.addTarget(self, action: #selector(copyLog), for: .touchUpInside)
            infoBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            let infoBtnBtnItem:UIBarButtonItem = UIBarButtonItem(customView: infoBtn)
            
            self.navigationItem.rightBarButtonItem = infoBtnBtnItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logTextView.text = readLog()
    }
    
    @objc func copyLog() -> Void {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.logTextView.text
            Utils.showBanner(in: self.view.subviews.first!, type: .success, text: LocalizedStrings.walletLogCopied)
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
