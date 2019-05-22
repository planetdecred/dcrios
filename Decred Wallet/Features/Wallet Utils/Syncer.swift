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
    func onStarted()
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32)
    func onHeadersFetchProgress(_ progressReport: HeadersFetchProgressReport)
    func onAddressDiscoveryProgress(_ progressReport: AddressDiscoveryProgressReport)
    func onHeadersRescanProgress(_ progressReport: HeadersRescanProgressReport)
    func onSyncCompleted()
    func onSyncCanceled()
    func onSyncEndedWithError(_ error: String)
    func debug(_ totalTimeElapsed: Int64, _ totalTimeRemaining: Int64, _ currentStageTimeElapsed: Int64, _ currentStageTimeRemaining: Int64)
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
        AppDelegate.walletLoader.wallet?.addEstimatedSyncProgressListener(self, logEstimatedProgress: true)
    }
    
    func beginSync() {
        self.networkLastActive = nil
        self.currentSyncOp = nil
        self.currentSyncOpProgress = nil
        self.shouldRestartSync = false
        
        do {
            let userSetSPVPeerIPs = Settings.readOptionalValue(for: Settings.Keys.SPVPeerIP) ?? ""
            try AppDelegate.walletLoader.wallet?.spvSync(userSetSPVPeerIPs)
            
            self.forEachSyncListener({ syncListener in syncListener.onStarted() })
            
            // Listen for changes to app state, specifically when the app becomes active after being suspended previously.
            AppDelegate.shared.registerLifeCylceDelegate(self, for: "\(self)")
        } catch (let syncError) {
            AppDelegate.shared.showOkAlert(message: syncError.localizedDescription, title: "Sync error")
        }
    }
    
    func restartSync() {
        if self.syncCompletedCanceledOrErrored {
            // sync not in progress, restart now
            self.currentSyncOp = nil
            self.currentSyncOpProgress = nil
            self.beginSync()
        } else {
            self.currentSyncOp = nil
            self.currentSyncOpProgress = nil
            self.shouldRestartSync = true
            AppDelegate.walletLoader.wallet?.cancelSync()
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
                listener.onHeadersFetchProgress(self.currentSyncOpProgress as! HeadersFetchProgressReport)
                
            case .DiscoveringAddresses:
                listener.onAddressDiscoveryProgress(self.currentSyncOpProgress as! AddressDiscoveryProgressReport)
                
            case .RescanningHeaders:
                listener.onHeadersRescanProgress(self.currentSyncOpProgress as! HeadersRescanProgressReport)
                
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
        
        if AppDelegate.shared.reachability.connection == .none {
            // No network connection as app enters foreground, but sync was in progress.
            // Update network last active time and wait for network reconnection before accounting for total lost time.
            if self.networkLastActive == nil || lastActiveTime.isBefore(self.networkLastActive!) {
                self.networkLastActive = lastActiveTime
            }
            return
        }
        
        var syncLastActive = lastActiveTime
        if self.networkLastActive != nil && self.networkLastActive!.isBefore(lastActiveTime) {
            // Use network last active time if network was lost before app went to sleep.
            syncLastActive = self.networkLastActive!
        }
        
        let totalInactiveSeconds = Date().timeIntervalSince(syncLastActive)
        AppDelegate.walletLoader.wallet?.syncInactive(forPeriod: Int64(totalInactiveSeconds))
        self.networkLastActive = nil // Network is active at this point.
    }

    func networkChanged(_ connection: Reachability.Connection) {
        if self.syncCompletedCanceledOrErrored {
            // sync is not currently active, no need to worry about network changes
            return
        }
        
        if connection == .none {
            self.networkLastActive = Date()
        } else if self.networkLastActive != nil {
            // network was active before, then got disconnected, subtract lost time from sync estimation parameters
            let totalInactiveSeconds = Date().timeIntervalSince(self.networkLastActive!)
            AppDelegate.walletLoader.wallet?.syncInactive(forPeriod: Int64(totalInactiveSeconds))
            self.networkLastActive = nil // Network is active at this point.
        }
    }
}

// Extension for receiving estimated sync progress report from dcrlibwallet sync process.
// Progress report is decoded from the received Json string back to the original data format in the same dcrlibwallet background thread.
extension Syncer: DcrlibwalletEstimatedSyncProgressJsonListenerProtocol {
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        self.connectedPeersCount = numberOfConnectedPeers
        self.forEachSyncListener({ syncListener in syncListener.onPeerConnectedOrDisconnected(numberOfConnectedPeers) })
    }
    
    func onHeadersFetchProgress(_ headersFetchProgressJson: String?) {
        self.decodeProgressReport(headersFetchProgressJson, for: HeadersFetchProgressReport.self) { progressReport in
            self.currentSyncOp = .FetchingHeaders
            self.currentSyncOpProgress = progressReport
            self.forEachSyncListener({ syncListener in syncListener.onHeadersFetchProgress(progressReport) })
        }
    }
    
    func onAddressDiscoveryProgress(_ addressDiscoveryProgressJson: String?) {
        self.decodeProgressReport(addressDiscoveryProgressJson, for: AddressDiscoveryProgressReport.self) { progressReport in
            self.currentSyncOp = .DiscoveringAddresses
            self.currentSyncOpProgress = progressReport
            self.forEachSyncListener({ syncListener in syncListener.onAddressDiscoveryProgress(progressReport) })
        }
    }
    
    func onHeadersRescanProgress(_ headersRescanProgressJson: String?) {
        self.decodeProgressReport(headersRescanProgressJson, for: HeadersRescanProgressReport.self) { progressReport in
            self.currentSyncOp = .RescanningHeaders
            self.currentSyncOpProgress = progressReport
            self.forEachSyncListener({ syncListener in syncListener.onHeadersRescanProgress(progressReport) })
        }
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
    
    func onSyncEndedWithError(_ err: String?) {
        print("sync error: \(err!)")
        self.currentSyncOp = .Errored
        self.currentSyncOpProgress = err!
        self.forEachSyncListener({ syncListener in syncListener.onSyncEndedWithError(err!) })
        
        if self.shouldRestartSync {
            self.beginSync()
        }
    }
    
    func decodeProgressReport<T: Decodable>(_ reportJson: String?, for reportType: T.Type, _ handleProgressReport: (_ progressReport: T) -> Void) {
        do {
            let progressReport = try JSONDecoder().decode(reportType, from: reportJson!.utf8Bits)
            handleProgressReport(progressReport)
        } catch (let error) {
            print("sync progress json decode error: \(error.localizedDescription)")
        }
    }
    
    func debug(_ totalTimeElapsed: Int64, totalTimeRemaining: Int64, currentStageTimeElapsed: Int64, currentStageTimeRemaining: Int64) {
        self.forEachSyncListener({ syncListener in
            syncListener.debug(totalTimeElapsed, totalTimeRemaining, currentStageTimeElapsed, currentStageTimeRemaining)
        })
    }
}
