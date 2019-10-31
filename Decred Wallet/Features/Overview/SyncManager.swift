//
//  SyncManager.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import Dcrlibwallet
import Signals

class SyncManager: NSObject, SyncProgressListenerProtocol {
    
    static let shared = SyncManager()
    
    var syncing = Signal<(Bool, String?)>()
    let syncProgress =  Signal<(DcrlibwalletGeneralSyncProgress?, DcrlibwalletHeadersFetchProgressReport?)>()
    var peers = Signal<Int32>()
    var syncStage = Signal<(Int, String)>()
    var connectedToNetwork: ((_ status: Bool) -> Void)?
    
    override init() {
        super.init()
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
        AppDelegate.walletLoader.syncer.registerEstimatedSyncProgressListener()
        self.connectedToNetwork?(false) // we assume wallet is offline on startup
        self.checkNetworkConnectionForSync()
    }
    
    func checkNetworkConnectionForSync() {
        // Re-trigger app network change listener to ensure correct network status is determined.
        AppDelegate.shared.listenForNetworkChanges()
        
        if AppDelegate.shared.reachability.connection == .none {
            DispatchQueue.main.async {
                let noConnectionAlert = UIAlertController(title: LocalizedStrings.internetConnectionRequired, message: LocalizedStrings.cannotSyncWithoutNetworkConnection, preferredStyle: .alert)
                noConnectionAlert.addAction(UIAlertAction(title: LocalizedStrings.ok, style: .default, handler: nil))
                AppDelegate.shared.window?.rootViewController?.present(noConnectionAlert, animated: false, completion: self.checkSyncPermission)
                self.connectedToNetwork?(false)
            }
        } else {
            self.checkSyncPermission()
        }
    }
    
    func checkSyncPermission() {
        if AppDelegate.shared.reachability.connection == .none {
            self.syncNotStartedDueToNetwork()
        } else if AppDelegate.shared.reachability.connection == .wifi || Settings.syncOnCellular {
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
            self.connectedToNetwork?(false)
        }
    }
    
    func startSync(isRestarting: Bool = false) {
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.connectedToNetwork?(true)
        }
        _ = isRestarting ? AppDelegate.walletLoader.syncer.restartSync() : AppDelegate.walletLoader.syncer.beginSync()
    }
    
    func onSyncEndedWithError(_ error: String) {
        self.syncing => (false, LocalizedStrings.walletNotSynced)
    }
    
    func onStarted(_ wasRestarted: Bool) {
        if (AppDelegate.walletLoader.wallet?.isSyncing() == false) {
            DispatchQueue.main.async {
                let statusMessage = wasRestarted ? LocalizedStrings.restartingSynchronization : LocalizedStrings.startingSynchronization
                self.syncing => (true, statusMessage)
            }
        }
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        let progress = Float(progressReport.headersFetchProgress) / 100.0
        self.syncStage => (1, String(format: LocalizedStrings.syncStageDescription, LocalizedStrings.fetchingBlockHeaders, progress))
        self.syncProgress => (progressReport.generalSyncProgress!, progressReport)
        self.syncing => (true, LocalizedStrings.synchronizing)
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
            self.syncing => (false, nil)
        }
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        self.peers => numberOfConnectedPeers
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        self.syncing => (false, willRestart ? LocalizedStrings.restartingSynchronization : nil)
    }
    
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {
        
    }
}
