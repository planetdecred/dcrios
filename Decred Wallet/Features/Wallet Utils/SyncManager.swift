//
//  SyncManager.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class SyncManager: NSObject, SyncProgressListenerProtocol {
    static let shared = SyncManager()
    
    override init() {
        super.init()
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
        AppDelegate.walletLoader.syncer.registerEstimatedSyncProgressListener()
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
        print("Sync ended with error: \(error)") // for debugging purpose
    }
    
    func onStarted(_ wasRestarted: Bool) {
        
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        // TODO: Generate signal event to notify listening views
    }
    
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport) {
        // TODO: Generate signal event to notify listening views
    }
    
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport) {
        // TODO: Generate signal event to notify listening views
    }
    
    func onSyncCompleted() {
        // TODO: Generate signal event to notify listening views
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        // TODO: Generate signal event to notify listening views
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        // TODO: Generate signal event to notify listening views
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {
        // TODO: show full debug information on long press of show sync details button
    }
}
