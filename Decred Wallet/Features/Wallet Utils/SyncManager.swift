//
//  SyncManager.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import Signals

class SyncManager: NSObject, SyncProgressListenerProtocol {
    static let shared = SyncManager()
    
    var peers: Signal = Signal<Int32>()
    var syncStatus: Signal = Signal<(Bool, String?)>()
    var syncProgress =  Signal<(DcrlibwalletGeneralSyncProgress?, Any?)>()
    
    // This is a custom listener for current sync operation/stage. the current sync operation can be deduced as a number
    // 1 => fetching headers. 2 => discovering address, 3 => rescanning headers
    var syncStage = Signal<(Int, String)>()
    var networkConnectionStatus: ((_ status: Bool) -> Void)?
    var isResartingSync = false
    
    override init() {
        super.init()
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
        AppDelegate.walletLoader.syncer.registerEstimatedSyncProgressListener()
        self.networkConnectionStatus?(false) // We assume network is not connected on launch
    }
    
    func checkNetworkConnectionForSync() {
        // Re-trigger app network change listener to ensure correct network status is determined.
        AppDelegate.shared.listenForNetworkChanges()
        
        if AppDelegate.shared.reachability.connection == .none {
            DispatchQueue.main.async {
                let noConnectionAlert = UIAlertController(title: LocalizedStrings.internetConnectionRequired, message: LocalizedStrings.cannotSyncWithoutNetworkConnection, preferredStyle: .alert)
                noConnectionAlert.addAction(UIAlertAction(title: LocalizedStrings.ok, style: .default, handler: nil))
                AppDelegate.shared.window?.rootViewController?.present(noConnectionAlert, animated: false, completion: self.checkSyncPermission)
            }
        } else {
            self.checkSyncPermission()
        }
    }
    
    func checkSyncPermission() {
        if AppDelegate.shared.reachability.connection == .none {
            self.syncNotStartedDueToNetwork()
        } else if AppDelegate.shared.reachability.connection == .wifi || Settings.syncOnCellular {
            self.networkConnectionStatus?(true) // Network is available, update any listening views
            self.startSync(isRestarting: isResartingSync)
        } else {
            self.requestPermissionToSync()
        }
    }
    
    func requestPermissionToSync() {
        let syncConfirmationDialog = UIAlertController(title: LocalizedStrings.internetConnectionRequired, message: LocalizedStrings.cannotSyncWithoutNetworkConnection, preferredStyle: .alert)
        
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.allowOnce, style: .default, handler: { action in
            self.startSync(isRestarting: self.isResartingSync)
        })) // Allow once selected
        
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.alwaysAllow, style: .default, handler: { action in
            Settings.setValue(true, for: Settings.Keys.SyncOnCellular)
            self.startSync(isRestarting: self.isResartingSync)
        })) // Always allow even on cellular selected
        
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.notNow, style: .cancel, handler: { action in
            self.syncNotStartedDueToNetwork()
        })) // Not now selected. Do not sync
        
        DispatchQueue.main.async {
            AppDelegate.shared.window?.rootViewController?.present(syncConfirmationDialog, animated: true, completion: nil)
        }
    }
    
    func syncNotStartedDueToNetwork() {
        AppDelegate.walletLoader.syncer.deRegisterSyncProgressListener(for: "\(self)")
        AppDelegate.walletLoader.multiWallet.cancelSync()
        
        // Allow 0.5 seconds for sync cancellation to complete before setting up wallet.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppDelegate.walletLoader.syncer.assumeSyncCompleted()
            self.onSyncEndedWithError(LocalizedStrings.connectToWiFiToSync)
            self.networkConnectionStatus?(false)
        }
    }
    
    
    func startSync(isRestarting: Bool) {
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
        
        // We want to start sync after determining if we are restarting or not.
        if isRestarting {
            AppDelegate.walletLoader.syncer.restartSync()
        } else {
            AppDelegate.walletLoader.syncer.beginSync()
        }
    }
    
    func onSyncEndedWithError(_ error: String) {
        self.syncStatus => (false, LocalizedStrings.walletNotSynced)
        self.networkConnectionStatus?(false)
        print("Sync ended with error: \(error)") // for debugging purpose
    }
    
    func onStarted(_ wasRestarted: Bool) {
        let statusMessage = wasRestarted ? LocalizedStrings.restartingSync : LocalizedStrings.startingSynchronization
        self.syncStatus => (true, statusMessage)
        self.peers => AppDelegate.walletLoader.syncer.connectedPeersCount
        self.networkConnectionStatus?(true)
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        let progress = Float(progressReport.headersFetchProgress) / 100.0
        self.syncStage => (1, String(format: LocalizedStrings.syncStageDescription, LocalizedStrings.fetchingBlockHeaders, progress))
        self.syncProgress => (progressReport.generalSyncProgress!, progressReport)
        self.syncStatus => (true, LocalizedStrings.synchronizing)
        self.peers => AppDelegate.walletLoader.syncer.connectedPeersCount
    }
    
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport) {
        self.syncStage => (2, LocalizedStrings.discoveringUsedAddresses)
        self.syncProgress => (progressReport.generalSyncProgress!, progressReport)
        self.peers => AppDelegate.walletLoader.syncer.connectedPeersCount
    }
    
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport) {
        if progressReport.generalSyncProgress == nil{
            return
        }else{
            let progress = Float(progressReport.rescanProgress) / 100.0
            self.syncProgress => (progressReport.generalSyncProgress!, progressReport)
            self.syncStage => (3, String(format: LocalizedStrings.syncStageDescription, LocalizedStrings.scanningBlocks, progress))
            self.peers => AppDelegate.walletLoader.syncer.connectedPeersCount
        }
    }
    
    func onSyncCompleted() {
        if (AppDelegate.walletLoader.multiWallet.isSynced() == true) {
            AppDelegate.walletLoader.syncer.deRegisterSyncProgressListener(for: "\(self)")
            self.syncStatus => (false, nil)
            self.peers => AppDelegate.walletLoader.syncer.connectedPeersCount
        }
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        self.peers => numberOfConnectedPeers
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        self.syncStatus => (false, willRestart ? LocalizedStrings.restartingSync : nil)
        self.peers => AppDelegate.walletLoader.syncer.connectedPeersCount
        self.networkConnectionStatus?(false)
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {
        // TODO: show full debug information on long press of show sync details button
    }
    
    func setBestBlockAge() -> String {
        if AppDelegate.walletLoader.multiWallet.isRescanning() {
            return ""
        }
        
        let bestBlockAge = Int64(Date().timeIntervalSince1970) - AppDelegate.walletLoader.wallet!.getBestBlockTimeStamp()
        
        switch bestBlockAge {
        case Int64.min...0:
            return LocalizedStrings.now
            
        case 0..<Utils.TimeInSeconds.Minute:
            return String(format: LocalizedStrings.secondsAgo, bestBlockAge)
            
        case Utils.TimeInSeconds.Minute..<Utils.TimeInSeconds.Hour:
            let minutes = bestBlockAge / Utils.TimeInSeconds.Minute
            return String(format: LocalizedStrings.minAgo, minutes)
            
        case Utils.TimeInSeconds.Hour..<Utils.TimeInSeconds.Day:
            let hours = bestBlockAge / Utils.TimeInSeconds.Hour
            return String(format: LocalizedStrings.hrsAgo, hours)
            
        case Utils.TimeInSeconds.Day..<Utils.TimeInSeconds.Week:
            let days = bestBlockAge / Utils.TimeInSeconds.Day
            return String(format: LocalizedStrings.daysAgo, days)
            
        case Utils.TimeInSeconds.Week..<Utils.TimeInSeconds.Month:
            let weeks = bestBlockAge / Utils.TimeInSeconds.Week
            return String(format: LocalizedStrings.weeksAgo, weeks)
            
        case Utils.TimeInSeconds.Month..<Utils.TimeInSeconds.Year:
            let months = bestBlockAge / Utils.TimeInSeconds.Month
            return String(format: LocalizedStrings.monthsAgo, months)
            
        default:
            let years = bestBlockAge / Utils.TimeInSeconds.Year
            return String(format: LocalizedStrings.yearsAgo, years)
        }
    }
}
