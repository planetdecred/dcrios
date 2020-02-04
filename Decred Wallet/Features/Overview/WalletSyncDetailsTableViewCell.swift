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
    
    func displayProgress(for wallet: DcrlibwalletWallet, lastProgressReport: Any?) {
        self.wallet = wallet
        self.walletNameLabel.text = wallet.name
        
        if self.wallet?.isWaiting() ?? true {
            self.walletSyncStatusLabel.text = LocalizedStrings.waitingForOtherWallets
            self.walletSyncStatusLabel.textColor = UIColor.appColors.darkGray
        } else {
            self.walletSyncStatusLabel.text = LocalizedStrings.synchronizing
            self.walletSyncStatusLabel.textColor = UIColor.appColors.green
        }
        
        if lastProgressReport == nil {
            self.resetSyncDetails()
        } else if let report = lastProgressReport as? DcrlibwalletHeadersFetchProgressReport {
            self.displayHeadersFetchProgressReport(report)
        } else if let report = lastProgressReport as? DcrlibwalletAddressDiscoveryProgressReport {
           self.displayAddressDiscoveryProgress(report)
        } else if let report = lastProgressReport as? DcrlibwalletHeadersRescanProgressReport {
            self.displayHeadersRescanProgress(report)
        }
    }
    
    func resetSyncDetails() {
        self.walletSyncCurrentStepTitleLabel.text = ""
        self.walletSyncCurrentStepReportLabel.text = ""
        self.walletSyncCurrentStepProgressLabel.text = ""
    }
    
    func displayHeadersFetchProgressReport(_ report: DcrlibwalletHeadersFetchProgressReport) {
        guard let wallet = self.wallet else { return }
        
        self.walletSyncCurrentStepTitleLabel.text = LocalizedStrings.blockHeadersFetched
        
        let currentHeaderHeight = wallet.isWaiting() ? wallet.getBestBlock() : report.currentHeaderHeight
        self.walletSyncCurrentStepReportLabel.text = String(format: LocalizedStrings.fetchedHeaders,
                                                            currentHeaderHeight,
                                                            report.totalHeadersToFetch)
        
        self.walletSyncCurrentStepProgressLabel.text = String(format: LocalizedStrings.bestBlockAgebehind,
                                                              report.bestBlockAge)
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
