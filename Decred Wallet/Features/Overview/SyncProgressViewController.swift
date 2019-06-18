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
        self.syncHeaderLabel.text = "Loading..."
        
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
    func onStarted(_ wasRestarted: Bool) {
        self.syncHeaderLabel.text = wasRestarted ? "Restarting Synchronization" : "Starting Synchronization"
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        var connectedPeers: String
        if numberOfConnectedPeers == 1 {
            connectedPeers = "\(numberOfConnectedPeers) peer"
        } else {
            connectedPeers = "\(numberOfConnectedPeers) peers"
        }
        self.connectedPeersLabel.text = "Syncing with \(connectedPeers) on \(self.netType!)."
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = "Fetched \(progressReport.fetchedHeadersCount) of ~\(progressReport.totalHeadersToFetch) block headers.\n"
        reportText += "\(progressReport.headersFetchProgress)% through step 1 of 3."
        if progressReport.bestBlockAge != "" {
            reportText += "\nYour wallet is \(progressReport.bestBlockAge) behind."
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = "Discovering used addresses.\n"
        if progressReport.addressDiscoveryProgress > 100 {
            reportText += "\(progressReport.addressDiscoveryProgress)% (over) through step 2 of 3."
        } else {
            reportText += "~\(progressReport.addressDiscoveryProgress)% through step 2 of 3."
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = "Scanning \(progressReport.currentRescanHeight) of \(progressReport.totalHeadersToScan) block headers.\n"
        reportText += "\(progressReport.rescanProgress)% through step 3 of 3."
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func handleGeneralProgressReport(_ generalProgress: DcrlibwalletGeneralSyncProgress) {
        self.syncHeaderLabel.text = "Synchronizing"
        
        self.generalSyncProgressBar.isHidden = false
        self.generalSyncProgressBar.progress = Float(generalProgress.totalSyncProgress) / 100.0
        
        self.generalSyncProgressLabel.text = "\(generalProgress.totalSyncProgress)% completed, \(generalProgress.totalTimeRemaining) remaining."
        
        // Display "show details" button if details are not being shown currently.
        self.showDetailedSyncReportButton.isHidden = !self.currentSyncActionReportLabel.isHidden
    }
    
    func onSyncCompleted() {
        AppDelegate.walletLoader.syncer.deRegisterSyncProgressListener(for: "\(self)")
        self.afterSyncCompletes?()
    }
    
    func onSyncCanceled() {
        self.resetSyncViews()
        self.syncHeaderLabel.text = "Synchronization canceled"
    }
    
    func onSyncEndedWithError(_ error: String) {
        self.resetSyncViews()
        self.syncHeaderLabel.text = "Synchronization error"
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.day, .hour, .minute, .second]
        timeFormatter.unitsStyle = .abbreviated
        
        let formatTime: (_ time: Int64) -> String = { time in
            return timeFormatter.string(from: TimeInterval(time))!
        }
        
        var debugSyncInfo = "All Times\n"
        debugSyncInfo += "elapsed: \(formatTime(debugInfo.totalTimeElapsed))"
        debugSyncInfo += " remain: \(formatTime(debugInfo.totalTimeRemaining))"
        debugSyncInfo += " total: \(formatTime(debugInfo.totalTimeElapsed + debugInfo.totalTimeRemaining))\n"
        
        debugSyncInfo += "Stage Times\n"
        debugSyncInfo += "elapsed: \(formatTime(debugInfo.currentStageTimeElapsed))"
        debugSyncInfo += " remain: \(formatTime(debugInfo.currentStageTimeRemaining))"
        debugSyncInfo += " total: \(formatTime(debugInfo.currentStageTimeElapsed + debugInfo.currentStageTimeRemaining))"
        
        self.debugSyncInfoLabel.text = debugSyncInfo
    }
}
