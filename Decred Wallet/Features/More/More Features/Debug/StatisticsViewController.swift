//
//  StatisticsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
//

import Foundation
import UIKit

class StatisticsViewController: UITableViewController  {
    @IBOutlet weak var buildDetailLabel: UILabel!
    
    @IBOutlet weak var peerConnectedDetailLabel: UILabel!
    @IBOutlet weak var uptimeDetailLabel: UILabel!
    @IBOutlet weak var networkDetailLabel: UILabel!
    @IBOutlet weak var bestBlockDetailLabel: UILabel!
    @IBOutlet weak var bestBlockTimestampDetailLabel: UILabel!
    
    @IBOutlet weak var bestBlockAgeDetailLabel: UILabel!
    @IBOutlet weak var walletFileDetailLabel: UILabel!
    @IBOutlet weak var chainDataDetailLabel: UILabel!
    
    @IBOutlet weak var transactionDetailLabel: UILabel!
    @IBOutlet weak var accountDetailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 36, right: 0)
        self.loadStatistcs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func loadStatistcs() {
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        self.buildDetailLabel.text = "\(BuildConfig.NetType), \(dateformater.string(from: AppDelegate.compileDate as Date))"
        self.peerConnectedDetailLabel.text = "\(WalletLoader.shared.multiWallet.connectedPeers())"
        
        let durationUpTime = Date().timeIntervalSince1970 - AppDelegate.appUpTime!
        self.uptimeDetailLabel.text = "\(Utils.timeStringFor(seconds: durationUpTime))"
        
        self.networkDetailLabel.text = "\(BuildConfig.NetType)"
        self.bestBlockDetailLabel.text = "\(WalletLoader.shared.multiWallet.getBestBlock()?.height ?? 0)"
        
        let bestBlockInfo = WalletLoader.shared.multiWallet.getBestBlock()
        let bestBlockAge = Int64(Date().timeIntervalSince1970) - bestBlockInfo!.timestamp
        self.bestBlockTimestampDetailLabel.text = "\(Date(timeIntervalSince1970: Double(bestBlockInfo!.timestamp)))"
        self.bestBlockAgeDetailLabel.text = Utils.calculateTime(timeInterval: bestBlockAge).lowercased()
        
        self.walletFileDetailLabel.text = "/Documents/dcrlibwallet/\(BuildConfig.NetType)/"
        self.chainDataDetailLabel.text = "\(Utils.format(bytes: Double(Utils.getDirFileSize())))"
        self.accountDetailLabel.text = "\(WalletLoader.shared.multiWallet.openedWalletsCount())"
        self.transactionDetailLabel.text = "\(Utils.countAllWalletTransaction())"
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
               //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
               
        self.addNavigationBackButton()
                   
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.statistics, style: .plain, target: self, action: nil)
               barButtonTitle.tintColor = UIColor.appColors.darkBlue
        if let barButtonReturn = self.navigationItem.leftBarButtonItem {
            self.navigationItem.leftBarButtonItems =
            [barButtonReturn, barButtonTitle]
        }
    }
}
