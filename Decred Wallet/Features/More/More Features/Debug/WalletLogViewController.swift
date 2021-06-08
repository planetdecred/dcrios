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
    @IBOutlet weak var loadingView: RoundedView!
    
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
            barButtonTitle.tintColor = UIColor.appColors.darkBlue
            
            self.navigationItem.leftBarButtonItems =  [ (self.navigationItem.leftBarButtonItem)!, barButtonTitle]
        
        let bottomHeight = (self.tabBarController?.tabBar.frame.height ?? 0) + 10
        self.logTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomHeight, right: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logTextView.text = readLog()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dismissView()
    }
    
    @objc func copyLog() -> Void {
        DispatchQueue.main.async {
            UIPasteboard.general.string = self.logTextView.text
            Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.walletLogCopied)
        }
    }
    
    private func showCopyButton() {
        //setup rightBar button
        let infoBtn = UIButton(type: .custom)
        infoBtn.setImage(UIImage(named: "ic_paste"), for: .normal)
        infoBtn.addTarget(self, action: #selector(copyLog), for: .touchUpInside)
        infoBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let infoBtnBtnItem:UIBarButtonItem = UIBarButtonItem(customView: infoBtn)

        self.navigationItem.rightBarButtonItem = infoBtnBtnItem
    }

    private func readLog() -> String {
        do {
            let logPath = "\(WalletLoader.appDataDir)/\(BuildConfig.NetType)/dcrlibwallet.log"
            let logContent = try String(contentsOf: URL(fileURLWithPath: logPath))
            let logEntries = logContent.split(separator: "\n")
            showCopyButton()
            if logEntries.count > 500 {
                loadingView.isHidden = true
                return logEntries.suffix(from: logEntries.count - 500).joined(separator: ";\n")
            } else {
                loadingView.isHidden = true
                return logEntries.suffix(from: 0).joined(separator: ";\n")
            }
        } catch (let error) {
            loadingView.isHidden = true
            Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
            return "Error loading log: \(error.localizedDescription)"
        }
    }
}
