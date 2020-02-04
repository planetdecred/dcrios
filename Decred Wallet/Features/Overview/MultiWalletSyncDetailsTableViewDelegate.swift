//
//  MultiWalletSyncDetailsTableViewDelegate.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class MultiWalletSyncDetailsTableViewDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    var multipleWalletsSyncDetailsTableView: UITableView
    
    var wallets: [DcrlibwalletWallet]
    var lastReceivedProgressReports: [Int:Any]
    
    init(for tableView: UITableView) {
        self.multipleWalletsSyncDetailsTableView = tableView
        
        self.wallets = WalletLoader.shared.wallets
        self.lastReceivedProgressReports = [Int:Any]()
        
        super.init()
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(WalletLoader.shared.multiWallet.loadedWalletsCount())
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let syncDetailsView = tableView.dequeueReusableCell(withIdentifier: "WalletSyncDetailsTableViewCell") as! WalletSyncDetailsTableViewCell
        
        let wallet = self.wallets[indexPath.row]
        syncDetailsView.displayProgress(for: wallet, lastProgressReport: self.lastReceivedProgressReports[wallet.id_])
        
        return syncDetailsView
    }
}

extension MultiWalletSyncDetailsTableViewDelegate: DcrlibwalletSyncProgressListenerProtocol {
    func onSyncStarted(_ wasRestarted: Bool) {
        // reset progress reports cache
        self.lastReceivedProgressReports = [Int:Any]()
        self.multipleWalletsSyncDetailsTableView.reloadData()
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
    }
    
    func onHeadersFetchProgress(_ headersFetchProgress: DcrlibwalletHeadersFetchProgressReport?) {
        guard let report = headersFetchProgress else { return }
        
        for wallet in self.wallets {
            self.lastReceivedProgressReports[wallet.id_] = report
        }
        self.multipleWalletsSyncDetailsTableView.reloadData()
    }
    
    func onAddressDiscoveryProgress(_ addressDiscoveryProgress: DcrlibwalletAddressDiscoveryProgressReport?) {
        if let report = addressDiscoveryProgress {
            self.lastReceivedProgressReports[report.walletID] = report
        }
    }
    
    func onHeadersRescanProgress(_ headersRescanProgress: DcrlibwalletHeadersRescanProgressReport?) {
        if let report = headersRescanProgress {
            self.lastReceivedProgressReports[report.walletID] = report
        }
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo?) {
    }
    
    func onSyncCompleted() {
        // reset progress reports cache
        self.lastReceivedProgressReports = [Int:Any]()
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        // reset progress reports cache
        self.lastReceivedProgressReports = [Int:Any]()
    }
    
    func onSyncEndedWithError(_ err: Error?) {
        // reset progress reports cache
        self.lastReceivedProgressReports = [Int:Any]()
    }
}
