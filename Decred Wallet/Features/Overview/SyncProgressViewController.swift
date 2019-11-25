//
//  SyncProgressViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

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
        self.syncHeaderLabel.text = LocalizedStrings.loading
        
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
        self.syncHeaderLabel.text = wasRestarted ? LocalizedStrings.restartingSynchronization : LocalizedStrings.startingSynchronization
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        var connectedPeers: String
        if numberOfConnectedPeers == 1 {
            connectedPeers = String(format: LocalizedStrings.numberOfConnectedPeer, numberOfConnectedPeers)
        } else {
            connectedPeers = String(format: LocalizedStrings.numberOfConnectedPeers, numberOfConnectedPeers)
        }
        self.connectedPeersLabel.text =  String(format: LocalizedStrings.syncingWithPeersOnNetwork, connectedPeers, self.netType!)
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = String(format: LocalizedStrings.fetchedHeaders, progressReport.fetchedHeadersCount, progressReport.totalHeadersToFetch)
        reportText += String(format: LocalizedStrings.headersFetchProgress, progressReport.headersFetchProgress)
        if progressReport.bestBlockAge != "" {
            reportText += String(format: LocalizedStrings.bestBlockAgebehind, progressReport.bestBlockAge)
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = "\(LocalizedStrings.discoveringUsedAddresses)\n"
        if progressReport.addressDiscoveryProgress > 100 {
            reportText += String(format: LocalizedStrings.addressDiscoveryProgressOver, progressReport.addressDiscoveryProgress)
        } else {
            reportText += String(format: LocalizedStrings.addressDiscoveryProgressThrough, progressReport.addressDiscoveryProgress)
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        var reportText = String(format: LocalizedStrings.scanningTotalHeaders, progressReport.currentRescanHeight, progressReport.totalHeadersToScan)
        reportText += String(format: LocalizedStrings.stepThreeRescanProgress, progressReport.rescanProgress)
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func handleGeneralProgressReport(_ generalProgress: DcrlibwalletGeneralSyncProgress) {
        self.syncHeaderLabel.text = LocalizedStrings.synchronizing
        
        self.generalSyncProgressBar.isHidden = false
        self.generalSyncProgressBar.progress = Float(generalProgress.totalSyncProgress) / 100.0
        
        self.generalSyncProgressLabel.text = String(format: LocalizedStrings.syncTotalProgress, generalProgress.totalSyncProgress, generalProgress.totalTimeRemaining)
        
        // Display "show details" button if details are not being shown currently.
        self.showDetailedSyncReportButton.isHidden = !self.currentSyncActionReportLabel.isHidden
    }
    
    func onSyncCompleted() {
        AppDelegate.walletLoader.syncer.deRegisterSyncProgressListener(for: "\(self)")
        self.afterSyncCompletes?()
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        self.resetSyncViews()
        self.syncHeaderLabel.text = willRestart ? LocalizedStrings.restartingSynchronization : LocalizedStrings.synchronizationCanceled
    }
    
    func onSyncEndedWithError(_ error: String) {
        self.resetSyncViews()
        self.syncHeaderLabel.text = LocalizedStrings.synchronizationError
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.day, .hour, .minute, .second]
        timeFormatter.unitsStyle = .abbreviated
        
        let formatTime: (_ time: Int64) -> String = { time in
            return timeFormatter.string(from: TimeInterval(time))!
        }
        
        var debugSyncInfo = "\(LocalizedStrings.allTimes)\n"
        debugSyncInfo += "\(LocalizedStrings.elapsed): \(formatTime(debugInfo.totalTimeElapsed))"
        debugSyncInfo += " \(LocalizedStrings.remain): \(formatTime(debugInfo.totalTimeRemaining))"
        debugSyncInfo += " \(LocalizedStrings.total): \(formatTime(debugInfo.totalTimeElapsed + debugInfo.totalTimeRemaining))\n"
        
        debugSyncInfo += "\(LocalizedStrings.stageTimes)\n"
        debugSyncInfo += "\(LocalizedStrings.elapsed): \(formatTime(debugInfo.currentStageTimeElapsed))"
        debugSyncInfo += " \(LocalizedStrings.remain): \(formatTime(debugInfo.currentStageTimeRemaining))"
        debugSyncInfo += " \(LocalizedStrings.total): \(formatTime(debugInfo.currentStageTimeElapsed + debugInfo.currentStageTimeRemaining))"
        
        self.debugSyncInfoLabel.text = debugSyncInfo
    }
}
