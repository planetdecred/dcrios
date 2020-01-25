//
//  SyncManager.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import Signals

class SyncManager: NSObject {
    static let shared = SyncManager()
    
    var stalledSyncTracker: Timer?
    var networkLastActive: Date?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var isSyncing: Bool {
        return WalletLoader.shared.multiWallet.isSyncing()
    }
    
    var isSynced: Bool {
        return WalletLoader.shared.multiWallet.isSynced()
    }
    
    var currentNetworkConnection: Reachability.Connection {
        // Re-trigger app network change listener to ensure correct network status is determined.
        AppDelegate.shared.listenForNetworkChanges()
        return AppDelegate.shared.reachability.connection
    }
    
    override init() {
        super.init()
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")
        WalletLoader.shared.multiWallet.enableSyncLogs()
    }
    
    func startOrRestartSync(allowSyncOnCellular: Bool) {
        // Check the updated network status before starting/restarting sync.
        if self.currentNetworkConnection == .none {
            self.requestInternetConnectionForSync()
            return
        }
        if self.currentNetworkConnection == .cellular && !allowSyncOnCellular {
            self.requestPermissionToSyncOnCellular()
            return
        }
        
        do {
            if WalletLoader.shared.multiWallet.isSyncing() {
                try WalletLoader.shared.multiWallet.restartSpvSync()
            } else {
                try WalletLoader.shared.multiWallet.spvSync()
            }
        } catch (let syncError) {
            AppDelegate.shared.showOkAlert(message: syncError.localizedDescription, title: LocalizedStrings.syncError)
        }
    }
    
    func requestInternetConnectionForSync() {
        let noConnectionAlert = UIAlertController(title: LocalizedStrings.internetConnectionRequired,
                                                  message: LocalizedStrings.cannotSyncWithoutNetworkConnection,
                                                  preferredStyle: .alert)
        
        noConnectionAlert.addAction(UIAlertAction(title: LocalizedStrings.ok, style: .default, handler: { _ in
            // Check if a network connection has been established and re-attempt to sync.
            if self.currentNetworkConnection != .none {
                self.startOrRestartSync(allowSyncOnCellular: Settings.syncOnCellular)
            } else if WalletLoader.shared.multiWallet.isSyncing() {
                // Cancel sync if sync was ongoing but there is no internet.
                WalletLoader.shared.multiWallet.cancelSync()
            }
        }))
        
        AppDelegate.shared.window?.rootViewController?.present(noConnectionAlert, animated: false)
    }
    
    func requestPermissionToSyncOnCellular() {
        // todo this title and message look wrong!
        let syncConfirmationDialog = UIAlertController(title: LocalizedStrings.internetConnectionRequired,
                                                       message: LocalizedStrings.cannotSyncWithoutNetworkConnection,
                                                       preferredStyle: .alert)
        
        // Dialog option to allow sync on cellular just once.
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.allowOnce, style: .default, handler: { _ in
            self.startOrRestartSync(allowSyncOnCellular: true)
        }))
        
        // Dialog option to ALWAYS allow syncing on cellular.
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.alwaysAllow, style: .default, handler: { _ in
            Settings.setValue(true, for: Settings.Keys.SyncOnCellular)
            self.startOrRestartSync(allowSyncOnCellular: true)
        }))
        
        // Dialog option to not use cellular network for now.
        syncConfirmationDialog.addAction(UIAlertAction(title: LocalizedStrings.notNow, style: .cancel, handler: { _ in
            if WalletLoader.shared.multiWallet.isSyncing() {
                // Cancel sync if sync was ongoing but user said not to use cellular network.
                WalletLoader.shared.multiWallet.cancelSync()
            }
        }))
        
        AppDelegate.shared.window?.rootViewController?.present(syncConfirmationDialog, animated: true)
    }
}

// extension to track delayed sync updates and restart sync
extension SyncManager: DcrlibwalletSyncProgressListenerProtocol {
    func onSyncStarted(_ wasRestarted: Bool) {
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
    }
    
    func onHeadersFetchProgress(_ headersFetchProgress: DcrlibwalletHeadersFetchProgressReport?) {
        self.restartSyncIfItStalls()
    }
    
    func onAddressDiscoveryProgress(_ addressDiscoveryProgress: DcrlibwalletAddressDiscoveryProgressReport?) {
        self.restartSyncIfItStalls()
    }
    
    func onHeadersRescanProgress(_ headersRescanProgress: DcrlibwalletHeadersRescanProgressReport?) {
        self.restartSyncIfItStalls()
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
    }
    
    func onSyncCompleted() {
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
    }
    
    func onSyncEndedWithError(_ err: Error?) {
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo?) {
    }
    
    func restartSyncIfItStalls() {
        // Cancel any previously set sync-restart timer.
        self.stalledSyncTracker?.invalidate()

        // No need to restart if sync is no longer in progress.
        if !self.isSyncing {
            return
        }

        // Setup new timer to restart sync in 30 seconds.
        // This timer would/should be canceled/invalidated if a sync update is received before the set interval (30 seconds).
        DispatchQueue.main.async {
            self.stalledSyncTracker = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) {_ in
                // No need to restart if sync is no longer in progress.
                guard self.isSyncing else { return }
                
                self.startOrRestartSync(allowSyncOnCellular: Settings.syncOnCellular)
                self.stalledSyncTracker = nil
            }
        }
    }
}

// extension to react to changes in application state or network connection:
/// - applicationWillEnterBackground:
///   Registers a background task to keep the sync process alive for a few minutes even after app enters background.
/// - applicationEnteredForegroundFromSuspendedState:
///   Accounts for any amount of time lost because the app was suspended causing the ongoing sync to stall.
/// - applicationWillTerminate:
///   Kills any previously registered background task when the app terminates.
/// - networkChanged:
///   Tracks network changes to account for any amount of time lost due to network unavailability causing the ongoing sync to stall.
extension SyncManager: AppLifeCycleDelegate {
    func applicationWillEnterBackground() {
        // Deregister any previous background task before registering a new one.
        // Especially when the user frequently switches between background and foreground states while sync is in progress.
        self.endBackgroundTask()
        
        if self.isSyncing && backgroundTask == .invalid {
            self.registerBackgroundTask()
            if let progress = WalletLoader.shared.multiWallet.generalSyncProgress() {
                fireLocalBackgroundSyncNotificationIfInBackground(with: progress)
            }
        }
    }
    
    func applicationEnteredForegroundFromSuspendedState(_ lastActiveTime: Date) {
        if !self.isSyncing {
            // sync is not currently active, no need to update sync estimation parameters
            return
        }
        
        // Sync was obviously stalled because the app went to sleep.
        // Unset any previous timer set to track stalled sync since we'd account for this particular stalling below.
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
        
        var syncLastActive = lastActiveTime
        if self.networkLastActive != nil && self.networkLastActive!.isBefore(lastActiveTime) {
            // Use network last active time if network was lost before app went to sleep.
            syncLastActive = self.networkLastActive!
        }
        
        let totalInactiveSeconds = Date().timeIntervalSince(syncLastActive)
        WalletLoader.shared.multiWallet.syncInactive(forPeriod: Int64(totalInactiveSeconds))
        
        if self.networkLastActive != nil && AppDelegate.shared.reachability.connection == .none {
            // Reset network last active time to current time so that when network connection is restored,
            // previously lost time (that was already accounted for above) would not be re-accounted for.
            self.networkLastActive = Date()
        }
    }
    
    func applicationWillTerminate() {
        print("app terminated")
        if backgroundTask != .invalid {
            endBackgroundTask()
        }
    }
    
    func networkChanged(_ connection: Reachability.Connection) {
        if !self.isSyncing {
            // sync is not currently active, no need to worry about network changes
            return
        }
        
        if connection == .none {
            self.networkLastActive = Date()
            // Network becoming disconnected may cause sync to stall for a while.
            // Unset any previous timer set to track stalled sync since we'd account
            // for this particular stalling below when network becomes active again.
            self.stalledSyncTracker?.invalidate()
            self.stalledSyncTracker = nil
        } else if self.networkLastActive != nil {
            // Account for stalled sync by subtracting lost time from sync estimation parameters.
            let totalInactiveSeconds = Date().timeIntervalSince(self.networkLastActive!)
            WalletLoader.shared.multiWallet.syncInactive(forPeriod: Int64(totalInactiveSeconds))
            self.networkLastActive = nil // Network is active at this point.
        }
    }
    
    private func registerBackgroundTask() {
        self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            print("Background task expired")
            self?.endBackgroundTask()
        }
        
        assert(backgroundTask != .invalid)
        print("Background task started at: ", Date())
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    private func endBackgroundTask() {
        NotificationsManager.shared.removeSyncInProgressNotification()
        if backgroundTask != .invalid {
            print("Background task ended at: ", Date())
            backgroundTask = .invalid
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
            }
        }
    }

    private func fireLocalBackgroundSyncNotificationIfInBackground(with progress: DcrlibwalletGeneralSyncProgress) {
         DispatchQueue.main.async {
            if !self.isSyncing || UIApplication.shared.applicationState != .background {
                return
            }
            
            let message = String(format: LocalizedStrings.syncTotalProgress,
                                 progress.totalSyncProgress,
                                 progress.totalTimeRemaining)
            NotificationsManager.shared.fireSyncInProgressNotification(with: message)
        }
    }
}
