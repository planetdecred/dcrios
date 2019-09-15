//
//  Syncer.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

protocol SyncProgressListenerProtocol {
    func onStarted(_ wasRestarted: Bool)
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32)
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport)
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport)
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport)
    func onSyncCompleted()
    func onSyncCanceled(_ willRestart: Bool)
    func onSyncEndedWithError(_ error: String)
    func debug(_ debugInfo: DcrlibwalletDebugInfo)
}

enum SyncOp {
    case FetchingHeaders
    case DiscoveringAddresses
    case RescanningHeaders
    case Done
    case Canceled
    case Errored
}

class Syncer: NSObject, AppLifeCycleDelegate {
    var syncListeners = [String : SyncProgressListenerProtocol]()
    
    var networkLastActive: Date?
    
    var stalledSyncTracker: Timer?
    
    var currentSyncOp: SyncOp?
    var currentSyncOpProgress: Any?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var syncCompletedCanceledOrErrored: Bool {
        return self.currentSyncOp == SyncOp.Done || self.currentSyncOp == SyncOp.Canceled || self.currentSyncOp == SyncOp.Errored
    }
    
    var connectedPeersCount: Int32 = 0
    var connectedPeers: String {
        if self.connectedPeersCount == 1 {
            return String(format: LocalizedStrings.numberOfConnectedPeer, connectedPeersCount)
        } else {
            return String(format: LocalizedStrings.numberOfConnectedPeers, connectedPeersCount)
        }
    }

    func registerEstimatedSyncProgressListener() {
        AppDelegate.walletLoader.wallet?.enableSyncLogs()
        // Following call should only throw an error if we attempt to add this sync progress listener multiple times.
        // Safe to ignore such error since it implies that this sync listener is already registered.
        try? AppDelegate.walletLoader.wallet?.add(self, uniqueIdentifier: "dcrios")
    }
    
    func resetSyncData() {
        self.networkLastActive = nil
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
        self.currentSyncOp = nil
        self.currentSyncOpProgress = nil
    }
    
    func beginSync() {
        // Listen for changes to app state, specifically when the app becomes active after being suspended previously.
        AppDelegate.shared.registerLifeCylceDelegate(self, for: "\(self)")
        
        self.resetSyncData()
        
        do {
            let userSetSPVPeerIPs = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
            try AppDelegate.walletLoader.wallet?.spvSync(userSetSPVPeerIPs)
          
            self.forEachSyncListener({ syncListener in syncListener.onStarted(false) })
        } catch (let syncError) {
            AppDelegate.shared.showOkAlert(message: syncError.localizedDescription, title: LocalizedStrings.syncError)
        }
    }
    
    func restartSync() {
        self.resetSyncData()
        do {
            let userSetSPVPeerIPs = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
            try AppDelegate.walletLoader.wallet?.restartSpvSync(userSetSPVPeerIPs)
            
            self.forEachSyncListener({ syncListener in syncListener.onStarted(true) })
        } catch (let syncError) {
            AppDelegate.shared.showOkAlert(message: syncError.localizedDescription, title: LocalizedStrings.syncError)
        }
    }
    
    func restartSyncIfItStalls() {
        // Cancel any previously set sync-restart timer.
        self.stalledSyncTracker?.invalidate()
        
        // Setup new timer to restart sync in 30 seconds.
        // This timer would/should be canceled/invalidated if a sync update is received before the set interval (30 seconds).
        DispatchQueue.main.async {
            self.stalledSyncTracker = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) {_ in
                if self.syncCompletedCanceledOrErrored {
                    // Sync not in progress, no need to restart.
                    return
                }
                self.restartSync()
                self.stalledSyncTracker = nil
            }
        }
    }
    
    func registerSyncProgressListener(for identifier: String, _ listener: SyncProgressListenerProtocol) {
        self.syncListeners[identifier] = listener
        
        // Report current status to newly added listener.
        // Especially important when a user navigates away from overview page during sync and returns to the page.
        // The listener is re-registered; this ensures that the UI is updated immediately.
        if self.currentSyncOp != nil {
            switch self.currentSyncOp! {
            case .FetchingHeaders:
                listener.onHeadersFetchProgress(self.currentSyncOpProgress as! DcrlibwalletHeadersFetchProgressReport)
                
            case .DiscoveringAddresses:
                listener.onAddressDiscoveryProgress(self.currentSyncOpProgress as! DcrlibwalletAddressDiscoveryProgressReport)
                
            case .RescanningHeaders:
                listener.onHeadersRescanProgress(self.currentSyncOpProgress as! DcrlibwalletHeadersRescanProgressReport)
                
            case .Done:
                listener.onSyncCompleted()
                
            case .Canceled:
                listener.onSyncCanceled(false)
                
            case .Errored:
                listener.onSyncEndedWithError(self.currentSyncOpProgress as! String)
            }
            
            listener.onPeerConnectedOrDisconnected(self.connectedPeersCount)
        }
    }
    
    func deRegisterSyncProgressListener(for identifier: String) {
        self.syncListeners.removeValue(forKey: identifier)
    }
    
    func assumeSyncCompleted() {
        self.onSyncCompleted()
    }
    
    func forEachSyncListener(_ callback: @escaping (_ syncListener: SyncProgressListenerProtocol) -> Void) {
        DispatchQueue.main.async {
            for (_, syncListener) in self.syncListeners {
                callback(syncListener)
            }
        }
    }

    func applicationEnteredForegroundFromSuspendedState(_ lastActiveTime: Date) {
        if self.syncCompletedCanceledOrErrored {
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
        AppDelegate.walletLoader.wallet?.syncInactive(forPeriod: Int64(totalInactiveSeconds))
        
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

    func applicationWillEnterBackground() {
        // Making sure we deregister any previous background task before registering a new one.
        // Especially when the user is switching between background and foreground states many times while sync is in progress
        endBackgroundTask()
        if !syncCompletedCanceledOrErrored && backgroundTask == .invalid {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            print("Background task started at: ", Date())
            registerBackgroundTask()
        }
    }

    func networkChanged(_ connection: Reachability.Connection) {
        if self.syncCompletedCanceledOrErrored {
            // sync is not currently active, no need to worry about network changes
            return
        }
        
        if connection == .none {
            self.networkLastActive = Date()
        } else if self.networkLastActive != nil {
            // Network was active before, then got disconnected. So, sync must have stalled for a while.
            // Unset any previous timer set to track stalled sync since we'd account for this particular stalling below.
            self.stalledSyncTracker?.invalidate()
            self.stalledSyncTracker = nil
            
            // Account for stalled sync by subtracting lost time from sync estimation parameters.
            let totalInactiveSeconds = Date().timeIntervalSince(self.networkLastActive!)
            AppDelegate.walletLoader.wallet?.syncInactive(forPeriod: Int64(totalInactiveSeconds))
            self.networkLastActive = nil // Network is active at this point.
        }
    }

    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("Background task ended at: ", Date())
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// Extension for receiving estimated sync progress report from dcrlibwallet sync process.
// Progress report is decoded from the received Json string back to the original data format in the same dcrlibwallet background thread.
extension Syncer: DcrlibwalletSyncProgressListenerProtocol {
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        self.connectedPeersCount = numberOfConnectedPeers
        self.forEachSyncListener({ syncListener in syncListener.onPeerConnectedOrDisconnected(numberOfConnectedPeers) })
    }
    
    func onHeadersFetchProgress(_ headersFetchProgress: DcrlibwalletHeadersFetchProgressReport?) {
        if !self.syncCompletedCanceledOrErrored {
            self.restartSyncIfItStalls()
        }
        
        self.currentSyncOp = .FetchingHeaders
        self.currentSyncOpProgress = headersFetchProgress
        self.forEachSyncListener({ syncListener in syncListener.onHeadersFetchProgress(headersFetchProgress!) })
    }
    
    func onAddressDiscoveryProgress(_ addressDiscoveryProgress: DcrlibwalletAddressDiscoveryProgressReport?) {
        if !self.syncCompletedCanceledOrErrored {
            self.restartSyncIfItStalls()
        }
        
        self.currentSyncOp = .DiscoveringAddresses
        self.currentSyncOpProgress = addressDiscoveryProgress
        self.forEachSyncListener({ syncListener in syncListener.onAddressDiscoveryProgress(addressDiscoveryProgress!) })
    }
    
    func onHeadersRescanProgress(_ headersRescanProgress: DcrlibwalletHeadersRescanProgressReport?) {
        // Do not set current sync op for blocks rescan.
        // Ideally, blocks rescan should notify a different callback than sync - rescan stage.
        if !AppDelegate.walletLoader.wallet!.isScanning() {
            self.currentSyncOp = .RescanningHeaders
            self.currentSyncOpProgress = headersRescanProgress
            
            if !self.syncCompletedCanceledOrErrored {
                self.restartSyncIfItStalls()
            }
        }
        
        self.forEachSyncListener({ syncListener in syncListener.onHeadersRescanProgress(headersRescanProgress!) })
    }
    
    func onSyncCompleted() {
        print("sync completed")
        
        // Unset any previous timer set to track stalled sync.
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
        
        self.currentSyncOp = .Done
        self.currentSyncOpProgress = nil
        self.forEachSyncListener({ syncListener in syncListener.onSyncCompleted() })

        let initialSyncCompleted: Bool? = Settings.readOptionalValue(for: Settings.Keys.InitialSyncCompleted)
        if initialSyncCompleted == nil {
            Settings.setValue(true, for: Settings.Keys.InitialSyncCompleted)
        }
        endBackgroundTask()
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        print("sync canceled")
        
        // Unset any previous timer set to track stalled sync.
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
        
        self.currentSyncOp = .Canceled
        self.currentSyncOpProgress = nil
        self.forEachSyncListener({ syncListener in syncListener.onSyncCanceled(willRestart) })
    }
    
    func onSyncEndedWithError(_ err: Error?) {
        print("sync error: \(err!)")
        
        // Unset any previous timer set to track stalled sync.
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
        
        self.currentSyncOp = .Errored
        self.currentSyncOpProgress = err!.localizedDescription
        self.forEachSyncListener({ syncListener in syncListener.onSyncEndedWithError(err!.localizedDescription) })
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo?) {
        self.forEachSyncListener({ syncListener in
            syncListener.debug(debugInfo!)
        })
    }
}
