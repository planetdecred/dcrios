//
//  Syncer.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 13/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//
import Foundation
import Dcrlibwallet

protocol SyncProgressListenerProtocol {
    func onStarted(_ wasRestarted: Bool)
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32)
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport)
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport)
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport)
    func onSyncCompleted()
    func onSyncCanceled()
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
    
    var syncCompletedCanceledOrErrored: Bool {
        return self.currentSyncOp == SyncOp.Done || self.currentSyncOp == SyncOp.Canceled || self.currentSyncOp == SyncOp.Errored
    }
    
    var shouldRestartSync: Bool = false
    
    var connectedPeersCount: Int32 = 0
    var connectedPeers: String {
        if self.connectedPeersCount == 1 {
            return "\(self.connectedPeersCount) peer"
        } else {
            return "\(self.connectedPeersCount) peers"
        }
    }
    
    func registerEstimatedSyncProgressListener() {
        AppDelegate.walletLoader.wallet?.enableSyncLogs()
        // Following call should only throw an error if we attempt to add this sync progress listener multiple times.
        // Safe to ignore such error since it implies that this sync listener is already registered.
        try? AppDelegate.walletLoader.wallet?.add(self, uniqueIdentifier: "dcrios")
    }
    
    func beginSync() {
        self.networkLastActive = nil
        self.stalledSyncTracker?.invalidate()
        self.stalledSyncTracker = nil
        self.currentSyncOp = nil
        self.currentSyncOpProgress = nil
        
        let isRestarting = self.shouldRestartSync
        self.shouldRestartSync = false
        
        do {
            let userSetSPVPeerIPs = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
            try AppDelegate.walletLoader.wallet?.spvSync(userSetSPVPeerIPs)
            
            self.forEachSyncListener({ syncListener in syncListener.onStarted(isRestarting) })
            
            // Listen for changes to app state, specifically when the app becomes active after being suspended previously.
            AppDelegate.shared.registerLifeCylceDelegate(self, for: "\(self)")
        } catch (let syncError) {
            AppDelegate.shared.showOkAlert(message: syncError.localizedDescription, title: "Sync error")
        }
    }
    
    func restartSync() {
        self.shouldRestartSync = true
        if self.syncCompletedCanceledOrErrored {
            // sync not in progress, restart now
            self.currentSyncOp = nil
            self.currentSyncOpProgress = nil
            self.beginSync()
        } else {
            self.currentSyncOp = nil
            self.currentSyncOpProgress = nil
            AppDelegate.walletLoader.wallet?.cancelSync()
        }
    }
    
    func restartSyncIfItStalls() {
        // Create time to restart sync in 30 seconds. Timer will be auto-canceled and recreated if a sync update is received before the 30 seconds elapse.
        self.stalledSyncTracker?.invalidate()
        DispatchQueue.main.async {
            self.stalledSyncTracker = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) {_ in
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
                listener.onSyncCanceled()
                
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
}

// Extension for receiving estimated sync progress report from dcrlibwallet sync process.
// Progress report is decoded from the received Json string back to the original data format in the same dcrlibwallet background thread.
extension Syncer: DcrlibwalletSyncProgressListenerProtocol {
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        self.connectedPeersCount = numberOfConnectedPeers
        self.forEachSyncListener({ syncListener in syncListener.onPeerConnectedOrDisconnected(numberOfConnectedPeers) })
    }
    
    func onHeadersFetchProgress(_ headersFetchProgress: DcrlibwalletHeadersFetchProgressReport?) {
        self.restartSyncIfItStalls()
        
        self.currentSyncOp = .FetchingHeaders
        self.currentSyncOpProgress = headersFetchProgress
        self.forEachSyncListener({ syncListener in syncListener.onHeadersFetchProgress(headersFetchProgress!) })
    }
    
    func onAddressDiscoveryProgress(_ addressDiscoveryProgress: DcrlibwalletAddressDiscoveryProgressReport?) {
        self.restartSyncIfItStalls()
        
        self.currentSyncOp = .DiscoveringAddresses
        self.currentSyncOpProgress = addressDiscoveryProgress
        self.forEachSyncListener({ syncListener in syncListener.onAddressDiscoveryProgress(addressDiscoveryProgress!) })
    }
    
    func onHeadersRescanProgress(_ headersRescanProgress: DcrlibwalletHeadersRescanProgressReport?) {
        if !AppDelegate.walletLoader.wallet!.isScanning() {
            // Do not set current sync op for blocks rescan.
            // Ideally, blocks rescan should notify a different callback than sync - rescan stage.
            self.currentSyncOp = .RescanningHeaders
            self.currentSyncOpProgress = headersRescanProgress
            self.restartSyncIfItStalls()
        }
        
        self.forEachSyncListener({ syncListener in syncListener.onHeadersRescanProgress(headersRescanProgress!) })
    }
    
    func onSyncCompleted() {
        print("sync completed")
        self.currentSyncOp = .Done
        self.currentSyncOpProgress = nil
        self.forEachSyncListener({ syncListener in syncListener.onSyncCompleted() })
    }
    
    func onSyncCanceled() {
        print("sync canceled")
        self.currentSyncOp = .Canceled
        self.currentSyncOpProgress = nil
        self.forEachSyncListener({ syncListener in syncListener.onSyncCanceled() })
        
        if self.shouldRestartSync {
            DispatchQueue.main.async {
                self.beginSync()
            }
        }
    }
    
    func onSyncEndedWithError(_ err: Error?) {
        print("sync error: \(err!)")
        self.currentSyncOp = .Errored
        self.currentSyncOpProgress = err!.localizedDescription
        self.forEachSyncListener({ syncListener in syncListener.onSyncEndedWithError(err!.localizedDescription) })
        
        if self.shouldRestartSync {
            DispatchQueue.main.async {
                self.beginSync()
            }
        }
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo?) {
        self.forEachSyncListener({ syncListener in
            syncListener.debug(debugInfo!)
        })
    }
}
