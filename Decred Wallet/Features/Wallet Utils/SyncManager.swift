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
    var syncProgress =  Signal<(DcrlibwalletGeneralSyncProgress?, DcrlibwalletHeadersFetchProgressReport?)>()
    
    // This is a custom listener for current sync operation/stage. the current sync operation can be deduced as a number
    // 1 => fetching headers. 2 => discovering address, 3 => rescanning headers
    var syncStage = Signal<(Int, String)>()
    var networkConnectionStatus: ((_ status: Bool) -> Void)?
    
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
            self.startSync()
        } else {
            self.requestPermissionToSync()
        }
    }
    
    func requestPermissionToSync() {
        let syncConfirmationDialog = UIAlertController(title: LocalizedStrings.internetConnectionRequired, message: LocalizedStrings.cannotSyncWithoutNetworkConnection, preferredStyle: .alert)
        
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.allowOnce, style: .default, handler: { action in
            self.startSync()
        })) // Allow once selected
        
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.alwaysAllow, style: .default, handler: { action in
            Settings.setValue(true, for: Settings.Keys.SyncOnCellular)
            self.startSync()
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
        AppDelegate.walletLoader.wallet?.cancelSync()
        
        // Allow 0.5 seconds for sync cancellation to complete before setting up wallet.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppDelegate.walletLoader.syncer.assumeSyncCompleted()
            self.onSyncEndedWithError(LocalizedStrings.connectToWiFiToSync)
        }
    }
    
    func startSync(isRestarting: Bool = false) {
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
        print("Sync ended with error: \(error)") // for debugging purpose
    }
    
    func onStarted(_ wasRestarted: Bool) {
        let statusMessage = wasRestarted ? LocalizedStrings.restartingSynchronization : LocalizedStrings.startingSynchronization
        self.syncStatus => (true, statusMessage)
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        let progress = Float(progressReport.headersFetchProgress) / 100.0
        self.syncStage => (1, String(format: LocalizedStrings.syncStageDescription, LocalizedStrings.fetchingBlockHeaders, progress))
        self.syncProgress => (progressReport.generalSyncProgress!, progressReport)
        self.syncStatus => (true, LocalizedStrings.synchronizing)
    }
    
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport) {
        self.syncStage => (2, LocalizedStrings.discoveringUsedAddresses)
    }
    
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport) {
        if progressReport.generalSyncProgress == nil{
            return
        }else{
            let progress = Float(progressReport.rescanProgress) / 100.0
            self.syncProgress => (progressReport.generalSyncProgress!, nil)
            self.syncStage => (3, String(format: LocalizedStrings.syncStageDescription, LocalizedStrings.scanningBlocks, progress))
        }
    }
    
    func onSyncCompleted() {
        if (AppDelegate.walletLoader.wallet?.isSynced() == true) {
            AppDelegate.walletLoader.syncer.deRegisterSyncProgressListener(for: "\(self)")
            self.syncStatus => (false, nil)
        }
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        self.peers => numberOfConnectedPeers
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        self.syncStatus => (false, willRestart ? LocalizedStrings.restartingSynchronization : nil)
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {
        // TODO: show full debug information on long press of show sync details button
    }
}
