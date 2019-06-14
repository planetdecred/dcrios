//
//  SyncProgressViewController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 14/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit
import Dcrlibwallet

class SyncProgressViewController: UIViewController {
    @IBOutlet weak var syncHeaderLabel: UILabel!
    @IBOutlet weak var generalSyncProgressBar: UIProgressView!
    @IBOutlet weak var generalSyncProgressLabel: UILabel!
    @IBOutlet weak var showDetailedSyncReportButton: UIButton!
    @IBOutlet weak var currentSyncActionReportLabel: UILabel!
    @IBOutlet weak var debugSyncInfoLabel: UILabel!
    @IBOutlet weak var connectedPeersLabel: UILabel!
    
    var netType: String?
    var afterSyncCompletes: (() -> Void)?
    
    override func viewDidLoad() {
        self.resetSyncViews()
        
        self.currentSyncActionReportLabel.addGestureRecognizer(self.hideDetailedSyncReportTapGesture())
        self.connectedPeersLabel.addGestureRecognizer(self.hideDetailedSyncReportTapGesture())
        
        self.currentSyncActionReportLabel.addGestureRecognizer(self.showOrHideDebugSyncReportLongPressGesture())
        self.debugSyncInfoLabel.addGestureRecognizer(self.showOrHideDebugSyncReportLongPressGesture())
        
        self.netType = BuildConfig.IsTestNet ? "testnet" : BuildConfig.NetType
        
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
    }
    
    func resetSyncViews() {
        self.syncHeaderLabel.text = "loading".localized
        
        self.generalSyncProgressBar.isHidden = true
        self.generalSyncProgressBar.progress = 0.0
        self.generalSyncProgressLabel.text = ""
        
        self.showDetailedSyncReportButton.isHidden = true
        
        self.currentSyncActionReportLabel.text = ""
        self.currentSyncActionReportLabel.isHidden = true
        
        self.debugSyncInfoLabel.text = ""
        self.debugSyncInfoLabel.isHidden = true
        
        self.connectedPeersLabel.text = ""
        self.connectedPeersLabel.isHidden = true
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
            self.debugSyncInfoLabel.isHidden = true
            self.connectedPeersLabel.isHidden = true
        })
    }
    
    func showOrHideDebugSyncReportLongPressGesture() -> UILongPressGestureRecognizer {
        return UILongPressGestureRecognizer(target: self, action: #selector(self.showOrHideDebugSyncReport))
    }
    
    @objc func showOrHideDebugSyncReport(_ sender: Any) {
        guard let longPress = sender as? UILongPressGestureRecognizer else {
            return
        }
        if longPress.state != .began {
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.debugSyncInfoLabel.isHidden = !self.debugSyncInfoLabel.isHidden
        })
    }
}

extension SyncProgressViewController: SyncProgressListenerProtocol {
    func onStarted() {
        self.syncHeaderLabel.text = "loading".localized
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        var connectedPeers: String
        if numberOfConnectedPeers == 1 {
            connectedPeers = String(format: "numberOfConnectedPeer".localized, numberOfConnectedPeers)
        } else {
            connectedPeers = String(format: "numberOfConnectedPeers".localized, numberOfConnectedPeers)
        }
        //self.connectedPeersLabel.text = String(format: "syncingWithOnNet".localized, connectedPeers, self.netType!)
        self.connectedPeersLabel.text = "Syncing with \(connectedPeers) on \(self.netType!)."
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = String(format: "fetchedHeaders".localized, progressReport.fetchedHeadersCount, progressReport.totalHeadersToFetch)
        reportText += String(format: "headersFetchProgress".localized, progressReport.headersFetchProgress)
        if progressReport.bestBlockAge != "" {
            //reportText += String(format: "bestBlockAgebehind".localized, progressReport.bestBlockAge)
            reportText += "\nYour wallet is \(progressReport.bestBlockAge) behind.";
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = "\("discoveringUsedAddresses".localized)\n"
        if progressReport.addressDiscoveryProgress > 100 {
            reportText += String(format: "addressDiscoveryProgressOver".localized,progressReport.addressDiscoveryProgress)
        } else {
            reportText += String(format: "addressDiscoveryProgressThrough".localized,progressReport.addressDiscoveryProgress)
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = String(format: "scanningTotalHeaders".localized, progressReport.currentRescanHeight,progressReport.totalHeadersToScan)
        reportText += String(format: "stepThreeRescanProgress".localized, progressReport.rescanProgress)
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func handleGeneralProgressReport(_ generalProgress: DcrlibwalletGeneralSyncProgress) {
        self.syncHeaderLabel.text = "synchronizing".localized
        
        self.generalSyncProgressBar.isHidden = false
        self.generalSyncProgressBar.progress = Float(generalProgress.totalSyncProgress) / 100.0
        
        self.generalSyncProgressLabel.text = String(format: "syncTotalProgress".localized, generalProgress.totalSyncProgress,generalProgress.totalTimeRemaining)
        
        // Display "show details" button if details are not being shown currently.
        self.showDetailedSyncReportButton.isHidden = !self.currentSyncActionReportLabel.isHidden
    }
    
    func onSyncCompleted() {
        AppDelegate.walletLoader.syncer.deRegisterSyncProgressListener(for: "\(self)")
        self.afterSyncCompletes?()
    }
    
    func onSyncCanceled() {
        self.resetSyncViews()
        self.syncHeaderLabel.text = "synchronizationCanceled".localized
    }
    
    func onSyncEndedWithError(_ error: String) {
        self.resetSyncViews()
        self.syncHeaderLabel.text = "synchronizationError".localized
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.day, .hour, .minute, .second]
        timeFormatter.unitsStyle = .abbreviated
        
        let formatTime: (_ time: Int64) -> String = { time in
            return timeFormatter.string(from: TimeInterval(time))!
        }
        
        var debugSyncInfo = "\("allTimes".localized)\n"
        debugSyncInfo += "\("elapsed".localized): \(formatTime(debugInfo.totalTimeElapsed))"
        debugSyncInfo += "\("remain".localized): \(formatTime(debugInfo.totalTimeRemaining))"
        debugSyncInfo += "\("total".localized): \(formatTime(debugInfo.totalTimeElapsed + debugInfo.totalTimeRemaining))\n"
        
        debugSyncInfo += "\("stageTimes".localized)\n"
        debugSyncInfo += "\("elapsed".localized): \(formatTime(debugInfo.currentStageTimeElapsed))"
        debugSyncInfo += "\("remain".localized): \(formatTime(debugInfo.currentStageTimeRemaining))"
        debugSyncInfo += "\("total".localized): \(formatTime(debugInfo.currentStageTimeElapsed + debugInfo.currentStageTimeRemaining))"
        
        self.debugSyncInfoLabel.text = debugSyncInfo
    }
}
