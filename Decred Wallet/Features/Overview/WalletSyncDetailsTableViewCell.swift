//
//  WalletSyncDetailsTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletSyncDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletSyncStatusLabel: UILabel!
    @IBOutlet weak var walletSyncCurrentStepTitleLabel: UILabel!
    @IBOutlet weak var walletSyncCurrentStepReportLabel: UILabel!
    @IBOutlet weak var walletSyncCurrentStepProgressLabel: UILabel!
    
    var wallet: DcrlibwalletWallet?
    
    func displayProgress(for wallet: DcrlibwalletWallet) {
        self.wallet = wallet
        self.walletNameLabel.text = wallet.name
        
        if wallet.isWaiting() {
            self.walletSyncStatusLabel.text = LocalizedStrings.waitingForOtherWallets
            self.walletSyncStatusLabel.textColor = UIColor.appColors.paleGray
        } else {
            self.walletSyncStatusLabel.text = LocalizedStrings.synchronizing
            self.walletSyncStatusLabel.textColor = UIColor.appColors.green
        }
        
        if WalletLoader.shared.multiWallet.currentSyncStage() == DcrlibwalletInvalidSyncStage {
            // sync is probably just starting
            self.walletSyncCurrentStepTitleLabel.text = ""
            self.walletSyncCurrentStepReportLabel.text = ""
            self.walletSyncCurrentStepProgressLabel.text = ""
            return
        }
        
        // If this wallet is fully synced, show stage 3 100% report.
        if wallet.isSynced() {
            self.walletSyncCurrentStepTitleLabel.text = LocalizedStrings.blockHeaderScanned
            
            let currentHeaderHeight = wallet.getBestBlock()
            self.walletSyncCurrentStepReportLabel.text = String(format: LocalizedStrings.scanningTotalHeaders, currentHeaderHeight, currentHeaderHeight)
            
            self.walletSyncCurrentStepProgressLabel.text = "100%"
            
            return
        }
        
        // This wallet is not fully synced, may be in stage 1, 2 or 3
        // or done with stage 1, waiting to start stage 2.
        // Show 100% progress report for stage 1 which would be ideal if waiting to start stage 2.
        // If this wallet is currently in stage 1, 2 or 3,
        // the progress report will be updated shortly from `MultiWalletSyncDetailsTableViewDelegate`
        // when that class registers a sync listener which would cause
        // the current stage progress report to be re-broadcasted.
        self.walletSyncCurrentStepTitleLabel.text = LocalizedStrings.blockHeadersFetched
        
        let currentHeaderHeight = wallet.getBestBlock()
        self.walletSyncCurrentStepReportLabel.text = String(format: LocalizedStrings.fetchedHeaders, currentHeaderHeight, currentHeaderHeight)
        
        let bestBlockAge = Utils.ageString(fromTimestamp: wallet.getBestBlockTimeStamp())
        self.walletSyncCurrentStepProgressLabel.text = String(format: LocalizedStrings.bestBlockAgebehind, bestBlockAge)
    }
    
    func displayHeadersFetchProgressReport(_ report: DcrlibwalletHeadersFetchProgressReport) {
        guard let wallet = self.wallet else { return }
        
        if wallet.isWaiting() {
            self.walletSyncStatusLabel.text = LocalizedStrings.waitingForOtherWallets
            self.walletSyncStatusLabel.textColor = UIColor.appColors.paleGray
        } else {
            self.walletSyncStatusLabel.text = LocalizedStrings.synchronizing
            self.walletSyncStatusLabel.textColor = UIColor.appColors.green
        }
        
        self.walletSyncCurrentStepTitleLabel.text = LocalizedStrings.blockHeadersFetched
        
        let currentHeaderHeight = wallet.isWaiting() ? wallet.getBestBlock() : report.currentHeaderHeight
        self.walletSyncCurrentStepReportLabel.text = String(format: LocalizedStrings.fetchedHeaders,
                                                            currentHeaderHeight,
                                                            report.totalHeadersToFetch)
        
        let bestBlockAge = wallet.isWaiting() ? Utils.ageString(fromTimestamp: wallet.getBestBlockTimeStamp()) : report.bestBlockAge
        self.walletSyncCurrentStepProgressLabel.text = String(format: LocalizedStrings.bestBlockAgebehind,
                                                              bestBlockAge)
    }
    
    func displayAddressDiscoveryProgress(_ report: DcrlibwalletAddressDiscoveryProgressReport) {
        guard let wallet = self.wallet, report.walletID == wallet.id_ else { return }
        
        self.walletSyncCurrentStepTitleLabel.text = LocalizedStrings.discoveringUsedAddresses
        self.walletSyncCurrentStepReportLabel.text = ""
        
        var reportFormat = LocalizedStrings.addressDiscoveryProgressThrough
        if report.addressDiscoveryProgress > 100 {
            reportFormat = LocalizedStrings.addressDiscoveryProgressOver
        }
        self.walletSyncCurrentStepProgressLabel.text = String(format: reportFormat, report.addressDiscoveryProgress)
    }
    
    func displayHeadersRescanProgress(_ report: DcrlibwalletHeadersRescanProgressReport) {
        guard let wallet = self.wallet, report.walletID == wallet.id_ else { return }
    
        self.walletSyncCurrentStepTitleLabel.text = LocalizedStrings.blockHeaderScanned
        self.walletSyncCurrentStepReportLabel.text = String(format: LocalizedStrings.scanningTotalHeaders, report.currentRescanHeight, report.totalHeadersToScan)
        
        self.walletSyncCurrentStepProgressLabel.text = "\(report.rescanProgress)%"
    }
}
