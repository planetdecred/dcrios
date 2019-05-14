//
//  SyncProgressViewController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 14/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

class SyncProgressViewController: UIViewController, SyncProgressListenerProtocol {
    @IBOutlet weak var syncHeaderLabel: UILabel!
    @IBOutlet weak var generalSyncProgressBar: UIProgressView!
    @IBOutlet weak var generalSyncProgressLabel: UILabel!
    @IBOutlet weak var showDetailedSyncReportButton: UIButton!
    @IBOutlet weak var currentSyncActionReportLabel: UILabel!
    @IBOutlet weak var connectedPeersLabel: UILabel!
    
    var netType: String?
    var afterSyncCompletes: (() -> Void)?
    
    func initialize() {
        self.syncHeaderLabel.text = "Loading..."
        self.generalSyncProgressBar.isHidden = true
        self.generalSyncProgressBar.progress = 0.0
        self.generalSyncProgressLabel.text = ""
        self.showDetailedSyncReportButton.isHidden = true
        
        self.currentSyncActionReportLabel.addGestureRecognizer(self.hideDetailedSyncReportTapGesture())
        self.connectedPeersLabel.addGestureRecognizer(self.hideDetailedSyncReportTapGesture())
        
        self.currentSyncActionReportLabel.text = ""
        self.currentSyncActionReportLabel.isHidden = true
        
        self.connectedPeersLabel.text = ""
        self.connectedPeersLabel.isHidden = true
        
        if GlobalConstants.App.IsTestnet {
            self.netType = "testnet"
        } else {
            self.netType = Utils.infoForKey(GlobalConstants.Strings.NetType)
        }
        
        WalletLoader.shared.syncer!.registerSyncProgressListener(for: "\(self)", self)
    }
    
    @IBAction func onTapShowDetailedSync(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.showDetailedSyncReportButton.isHidden = true
            self.currentSyncActionReportLabel.isHidden = false
            self.connectedPeersLabel.isHidden = false
        })
    }
    
    func hideDetailedSyncReportTapGesture() -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(self.hideDetailedSyncReport))
    }
    
    @objc func hideDetailedSyncReport() {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.showDetailedSyncReportButton.isHidden = false
            self.currentSyncActionReportLabel.isHidden = true
            self.connectedPeersLabel.isHidden = true
        })
    }
    
    func onGeneralSyncProgress(_ progressReport: GeneralSyncProgressReport) {
        if progressReport.done {
            WalletLoader.shared.syncer?.deRegisterSyncProgressListener(for: "\(self)")
            self.afterSyncCompletes?()
            return
        }
        
        self.syncHeaderLabel.text = "Synchronizing"
        
        self.generalSyncProgressBar.isHidden = false
        self.generalSyncProgressBar.progress = Float(progressReport.totalSyncProgress) / 100.0
        
        self.generalSyncProgressLabel.text = "\(progressReport.totalSyncProgress)% completed, \(progressReport.totalTimeRemaining) remaining."
        self.connectedPeersLabel.text = "Syncing with \(progressReport.peerCount) on \(self.netType!)."
        
        if self.connectedPeersLabel.isHidden {
            self.showDetailedSyncReportButton.isHidden = false
        }
    }
    
    func onHeadersFetchProgress(_ progressReport: HeadersFetchProgressReport) {
        var reportText = "Fetched \(progressReport.fetchedHeadersCount) of ~\(progressReport.totalHeadersToFetch) block headers.\n"
        reportText += "\(progressReport.headersFetchProgress)% through step 1 of 3."
        
        if progressReport.bestBlockAge != "" {
            reportText += "\nYour wallet is \(progressReport.bestBlockAge) behind."
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onAddressDiscoveryProgress(_ progressReport: AddressDiscoveryProgressReport) {
        var reportText = "Discovering used addresses.\n"
        
        if progressReport.addressDiscoveryProgress > 100 {
            reportText += "\(progressReport.addressDiscoveryProgress)% (over) through step 2 of 3."
        } else {
            reportText += "~\(progressReport.addressDiscoveryProgress)% through step 2 of 3."
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onHeadersRescanProgress(_ progressReport: HeadersRescanProgressReport) {
        var reportText = "Scanning \(progressReport.currentRescanHeight) of \(progressReport.totalHeadersToScan) block headers.\n"
        reportText += "\(progressReport.rescanProgress)% through step 3 of 3."
        
        self.currentSyncActionReportLabel.text = reportText
    }
}
