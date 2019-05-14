//
//  Syncer.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 13/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

protocol SyncProgressListenerProtocol {
    func onGeneralSyncProgress(_ progressReport: GeneralSyncProgressReport)
    func onHeadersFetchProgress(_ progressReport: HeadersFetchProgressReport)
    func onAddressDiscoveryProgress(_ progressReport: AddressDiscoveryProgressReport)
    func onHeadersRescanProgress(_ progressReport: HeadersRescanProgressReport)
}

enum SyncOp {
    case FetchingHeaders
    case DiscoveringAddresses
    case RescanningHeaders
}

class Syncer: NSObject {
    var syncListeners = [String : SyncProgressListenerProtocol]()
    
    var generalSyncProgress: GeneralSyncProgressReport?
    var currentSyncOp: SyncOp?
    var currentSyncOpProgress: Any?
    
    func beginSync() {
        self.generalSyncProgress = nil
        self.currentSyncOp = nil
        self.currentSyncOpProgress = nil
        
        DcrlibwalletSetLogLevels("off")
        WalletLoader.wallet?.addEstimatedSyncProgressListener(self)
        
        do {
            let userSetSPVPeerIPs = UserDefaults.standard.string(forKey: GlobalConstants.SettingsKeys.SPVPeerIP) ?? ""
            try WalletLoader.wallet?.spvSync(userSetSPVPeerIPs)
        } catch (let syncError) {
            AppDelegate.shared.showOkAlert(message: syncError.localizedDescription, title: "Sync error")
        }
    }
    
    func registerSyncProgressListener(for identifier: String, _ listener: SyncProgressListenerProtocol) {
        self.syncListeners[identifier] = listener
        
        guard let generalSyncProgress = self.generalSyncProgress else {
            return
        }
        
        // Report current status to newly added listener.
        // Especially important when a user navigates away from overview page during sync and returns to the page.
        // The listener is re-registered; this ensures that the UI is updated immediately.
        if !generalSyncProgress.done && self.currentSyncOp != nil {
            listener.onGeneralSyncProgress(generalSyncProgress)
            
            switch self.currentSyncOp! {
            case .FetchingHeaders:
                listener.onHeadersFetchProgress(self.currentSyncOpProgress as! HeadersFetchProgressReport)
                
            case .DiscoveringAddresses:
                listener.onAddressDiscoveryProgress(self.currentSyncOpProgress as! AddressDiscoveryProgressReport)
                
            case .RescanningHeaders:
                listener.onHeadersRescanProgress(self.currentSyncOpProgress as! HeadersRescanProgressReport)
            }
        }
    }
    
    func deRegisterSyncProgressListener(for identifier: String) {
        self.syncListeners.removeValue(forKey: identifier)
    }
}

// Extension for receiving estimated sync progress report from dcrlibwallet sync process.
// Progress report is decoded from the received Json string back to the original data format in the same dcrlibwallet background thread.
extension Syncer: DcrlibwalletEstimatedSyncProgressJsonListenerProtocol {
    func onGeneralSyncProgress(_ report: String?) {
        do {
            self.generalSyncProgress = try JSONDecoder().decode(GeneralSyncProgressReport.self, from: report!.utf8Bits)
            self.onGeneralSyncProgress(self.generalSyncProgress!)
        } catch (let error) {
            self.onError(error)
        }
    }
    
    func onHeadersFetchProgress(_ report: String?, generalProgress: String?) {
        do {
            self.generalSyncProgress = try JSONDecoder().decode(GeneralSyncProgressReport.self, from: generalProgress!.utf8Bits)
            self.onGeneralSyncProgress(self.generalSyncProgress!)
            
            let headersFetchProgress = try JSONDecoder().decode(HeadersFetchProgressReport.self, from: report!.utf8Bits)
            self.onHeadersFetchProgress(headersFetchProgress)
        } catch (let error) {
            self.onError(error)
        }
    }
    
    func onAddressDiscoveryProgress(_ report: String?, generalProgress: String?) {
        do {
            self.generalSyncProgress = try JSONDecoder().decode(GeneralSyncProgressReport.self, from: generalProgress!.utf8Bits)
            self.onGeneralSyncProgress(self.generalSyncProgress!)
            
            let addressDiscoveryProgress = try JSONDecoder().decode(AddressDiscoveryProgressReport.self, from: report!.utf8Bits)
            self.onAddressDiscoveryProgress(addressDiscoveryProgress)
        } catch (let error) {
            self.onError(error)
        }
    }
    
    func onHeadersRescanProgress(_ report: String?, generalProgress: String?) {
        do {
            self.generalSyncProgress = try JSONDecoder().decode(GeneralSyncProgressReport.self, from: generalProgress!.utf8Bits)
            self.onGeneralSyncProgress(self.generalSyncProgress!)
            
            let headersRescanProgress = try JSONDecoder().decode(HeadersRescanProgressReport.self, from: report!.utf8Bits)
            self.onHeadersRescanProgress(headersRescanProgress)
        } catch (let error) {
            self.onError(error)
        }
    }
    
    func onError(_ err: Error?) {
        print("estimated sync progress json encode/decode error: \(err!.localizedDescription)")
    }
}

// Extension for notifying UI sync listeners on main thread after progress report is decoded in previous extension.
extension Syncer: SyncProgressListenerProtocol {
    func onGeneralSyncProgress(_ progressReport: GeneralSyncProgressReport) {
        DispatchQueue.main.async {
            self.syncListeners.forEach({ (_, syncListener) in
                syncListener.onGeneralSyncProgress(progressReport)
            })
        }
        
        if progressReport.done {
            self.currentSyncOp = nil
            self.currentSyncOpProgress = nil
        }
    }
    
    func onHeadersFetchProgress(_ progressReport: HeadersFetchProgressReport) {
        DispatchQueue.main.async {
            for (_, syncListener) in self.syncListeners {
                syncListener.onHeadersFetchProgress(progressReport)
            }
        }
        
        if !self.generalSyncProgress!.done {
            self.currentSyncOp = .FetchingHeaders
            self.currentSyncOpProgress = progressReport
        }
    }
    
    func onAddressDiscoveryProgress(_ progressReport: AddressDiscoveryProgressReport) {
        DispatchQueue.main.async {
            for (_, syncListener) in self.syncListeners {
                syncListener.onAddressDiscoveryProgress(progressReport)
            }
        }
        
        if !self.generalSyncProgress!.done {
            self.currentSyncOp = .DiscoveringAddresses
            self.currentSyncOpProgress = progressReport
        }
    }
    
    func onHeadersRescanProgress(_ progressReport: HeadersRescanProgressReport) {
        DispatchQueue.main.async {
            for (_, syncListener) in self.syncListeners {
                syncListener.onHeadersRescanProgress(progressReport)
            }
        }
        
        if !self.generalSyncProgress!.done {
            self.currentSyncOp = .RescanningHeaders
            self.currentSyncOpProgress = progressReport
        }
    }
}
