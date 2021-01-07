//
//  MultiWalletSyncDetailsLoader.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class MultiWalletSyncDetailsLoader: NSObject, UITableViewDataSource, UITableViewDelegate {
    var multipleWalletsSyncDetailsTableView: UITableView
    
    var wallets: [DcrlibwalletWallet]
    
    static func setup(for multipleWalletsSyncDetailsTableView: UITableView) {
        let multiWalletSyncDetailsLoader = MultiWalletSyncDetailsLoader(multipleWalletsSyncDetailsTableView)
        multiWalletSyncDetailsLoader.reloadProgressViews()
    }
    
    private init(_ multipleWalletsSyncDetailsTableView: UITableView) {
        self.multipleWalletsSyncDetailsTableView = multipleWalletsSyncDetailsTableView
        self.wallets = WalletLoader.shared.wallets
        super.init()
        
        self.multipleWalletsSyncDetailsTableView.dataSource = self
        self.multipleWalletsSyncDetailsTableView.delegate = self
        
        try? WalletLoader.shared.multiWallet.add(self, uniqueIdentifier: "\(self)")
    }
    
    func reloadProgressViews() {
        self.multipleWalletsSyncDetailsTableView.reloadData()
        try? WalletLoader.shared.multiWallet.publishLastSyncProgress("\(self)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(WalletLoader.shared.multiWallet.loadedWalletsCount())
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let syncDetailsView = tableView.dequeueReusableCell(withIdentifier: "WalletSyncDetailsTableViewCell") as! WalletSyncDetailsTableViewCell
        syncDetailsView.displayProgress(for: self.wallets[indexPath.row])
        return syncDetailsView
    }
}

extension MultiWalletSyncDetailsLoader: DcrlibwalletSyncProgressListenerProtocol {
    func onSyncStarted(_ wasRestarted: Bool) {
        DispatchQueue.main.async {
            self.reloadProgressViews()
        }
    }
    
    func onCFiltersFetchProgress(_ cfiltersFetchProgress: DcrlibwalletCFiltersFetchProgressReport?) {
        guard let report = cfiltersFetchProgress else { return }
        
        DispatchQueue.main.async {
            for i in 0..<self.wallets.count {
                if let syncDetailsView = self.multipleWalletsSyncDetailsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? WalletSyncDetailsTableViewCell {
                    syncDetailsView.displayCFiltersFetchProgressReport(report)
                }
            }
        }
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
    }
    
    func onHeadersFetchProgress(_ headersFetchProgress: DcrlibwalletHeadersFetchProgressReport?) {
        guard let report = headersFetchProgress else { return }
        
        DispatchQueue.main.async {
            for i in 0..<self.wallets.count {
                if let syncDetailsView = self.multipleWalletsSyncDetailsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? WalletSyncDetailsTableViewCell {
                    syncDetailsView.displayHeadersFetchProgressReport(report)
                }
            }
        }
    }
    
    func onAddressDiscoveryProgress(_ addressDiscoveryProgress: DcrlibwalletAddressDiscoveryProgressReport?) {
        guard let report = addressDiscoveryProgress else {
            return
        }
        
        DispatchQueue.main.async {
            for i in 0..<self.wallets.count {
                if let syncDetailsView = self.multipleWalletsSyncDetailsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? WalletSyncDetailsTableViewCell {
                    syncDetailsView.displayAddressDiscoveryProgress(report)
                }
            }
        }
    }
    
    func onHeadersRescanProgress(_ headersRescanProgress: DcrlibwalletHeadersRescanProgressReport?) {
        guard let report = headersRescanProgress else {
            return
        }
        
        DispatchQueue.main.async {
            for i in 0..<self.wallets.count {
                if let syncDetailsView = self.multipleWalletsSyncDetailsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? WalletSyncDetailsTableViewCell {
                    syncDetailsView.displayHeadersRescanProgress(report)
                }
            }
        }
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo?) {
    }
    
    func onSyncCompleted() {
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
    }
    
    func onSyncEndedWithError(_ err: Error?) {
    }
}
