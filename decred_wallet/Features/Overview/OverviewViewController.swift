//
//  OverviewViewControllerr.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 11/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController {
    @IBOutlet weak var syncProgressViewContainer: UIView!
    @IBOutlet weak var syncHeaderLabel: UILabel!
    @IBOutlet weak var generalSyncProgressBar: UIProgressView!
    @IBOutlet weak var generalSyncProgressLabel: UILabel!
    @IBOutlet weak var showDetailedSyncReportButton: UIButton!
    @IBOutlet weak var currentSyncActionReportLabel: UILabel!
    @IBOutlet weak var connectedPeersLabel: UILabel!
    
    @IBOutlet weak var overviewPageContentView: UIView!
    @IBOutlet weak var recentActivityTableView: UITableView!
    @IBOutlet weak var fetchingBalanceIndicator: UIImageView!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    var recentTransactions = [Transaction]()
    
    override func viewDidLoad() {
        let initialSyncCompleted = WalletLoader.shared.syncer?.generalSyncProgress?.done ?? false
        if initialSyncCompleted {
            self.syncProgressViewContainer = nil
            self.initializeOverviewContent()
            return
        }
        
        self.initializeSyncViews()
        self.overviewPageContentView.isHidden = true
        self.view.addSubview(self.syncProgressViewContainer)
        WalletLoader.shared.syncer?.registerSyncProgressListener(for: "\(self)", self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar(withTitle: "Overview")
    }
    
    func initializeSyncViews() {
        self.syncHeaderLabel.text = "Loading..."
        self.generalSyncProgressBar.isHidden = true
        self.generalSyncProgressBar.progress = 0.0
        self.generalSyncProgressLabel.text = ""
        self.currentSyncActionReportLabel.text = ""
        self.connectedPeersLabel.text = ""
    }
    
    func initializeOverviewContent() {
        self.fetchingBalanceIndicator.loadGif(name: "progress bar-1s-200px")
        self.updateCurrentBalance()
        
        self.recentActivityTableView.registerCellNib(TransactionTableViewCell.self)
        self.recentActivityTableView.delegate = self
        self.recentActivityTableView.dataSource = self
        self.loadRecentActivity()
        
        let pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.addTarget(self, action: #selector(self.handleRecentActivityTableRefresh(_:)), for: UIControl.Event.valueChanged)
        pullToRefreshControl.tintColor = UIColor.lightGray
        self.recentActivityTableView.addSubview(pullToRefreshControl)
        
        self.overviewPageContentView.isHidden = false
    }
    
    func updateCurrentBalance() {
        self.totalBalanceLabel.isHidden = true
        self.fetchingBalanceIndicator.superview?.isHidden = false
        
        do {
            var getAccountsError: NSError?
            let accountsJson = WalletLoader.wallet?.getAccounts(0, error: &getAccountsError)
            if getAccountsError != nil {
                throw getAccountsError!
            }
            
            let accounts = try JSONDecoder().decode(WalletAccounts.self, from: accountsJson!.utf8Bits)
            let totalAmount = accounts.Acc.filter({ !$0.isHidden }).map({ $0.dcrTotalBalance }).reduce(0,+)
            let totalAmountRoundedOff = (Decimal(totalAmount) as NSDecimalNumber).round(8)
            
            self.totalBalanceLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: GlobalConstants.Colors.TextAmount)
            self.fetchingBalanceIndicator.superview?.isHidden = true
            self.totalBalanceLabel.isHidden = false
        } catch let error {
            print(error)
        }
    }
    
    @objc func handleRecentActivityTableRefresh(_ refreshControl: UIRefreshControl) {
        self.loadRecentActivity()
        refreshControl.endRefreshing()
    }
    
    func loadRecentActivity() {
        DispatchQueue.main.async {
            do {
                var getTransactionsError: NSError?
                let maxDisplayItems = round(self.recentActivityTableView.frame.size.height / TransactionTableViewCell.height())
                let transactionsJson = WalletLoader.wallet?.getTransactions(Int32(maxDisplayItems), error: &getTransactionsError)
                if getTransactionsError != nil {
                    throw getTransactionsError!
                }
                
                self.recentTransactions = try JSONDecoder().decode([Transaction].self, from: transactionsJson!.utf8Bits)
                self.recentActivityTableView.reloadData()
            } catch let Error {
                print(Error)
            }
        }
    }
    
    func removeSyncViewsFromPage() {
        for syncProgressView in self.syncProgressViewContainer.subviews {
            syncProgressView.removeFromSuperview()
        }
        self.syncProgressViewContainer.removeFromSuperview()
        self.syncProgressViewContainer = nil
    }
}

extension OverviewViewController: SyncProgressListenerProtocol {
    func onGeneralSyncProgress(_ progressReport: GeneralSyncProgressReport) {
        if progressReport.done {
            WalletLoader.shared.syncer?.deRegisterSyncProgressListener(for: "\(self)")
            self.removeSyncViewsFromPage()
            self.initializeOverviewContent()
            return
        }

        self.syncHeaderLabel.text = "Synchronizing"
        
        self.generalSyncProgressBar.isHidden = false
        self.generalSyncProgressBar.progress = Float(progressReport.totalSyncProgress) / 100.0
        
        self.generalSyncProgressLabel.text = "\(progressReport.totalSyncProgress)% completed, \(progressReport.totalTimeRemaining) remaining."
        
        var peerCount: String
        if progressReport.connectedPeers == 1 {
            peerCount = "\(progressReport.connectedPeers) peer"
        } else {
            peerCount = "\(progressReport.connectedPeers) peers"
        }
        self.connectedPeersLabel.text = "Syncing with \(peerCount) on \(WalletLoader.shared.netType!)."
    }
    
    func onHeadersFetchProgress(_ progressReport: HeadersFetchProgressReport) {
        var reportText = "Fetched \(progressReport.fetchedHeadersCount) of ~\(progressReport.totalHeadersToFetch) block headers.\n"
        reportText += "\(progressReport.headersFetchProgress)% through step 1 of 3."
        
        if progressReport.bestBlockAge != "" {
            reportText += "\nYour wallet is \(progressReport.bestBlockAge) behind."
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onAddressDiscoveryProgress(_ progressReport: AddressDiscoveryProgressReport) {
        var reportText = "Discovering used addresses.\n"
        
        if progressReport.addressDiscoveryProgress > 100 {
            reportText += "\(progressReport.addressDiscoveryProgress)% (over) through step 2 of 3."
        } else {
            reportText += "\(progressReport.addressDiscoveryProgress)% through step 2 of 3."
        }
        
        self.currentSyncActionReportLabel.text = reportText
    }
    
    func onHeadersRescanProgress(_ progressReport: HeadersRescanProgressReport) {
        var reportText = "Scanning \(progressReport.currentRescanHeight) of \(progressReport.totalHeadersToScan) block headers.\n"
        reportText += "\(progressReport.rescanProgress)% through step 3 of 3."
        
        self.currentSyncActionReportLabel.text = reportText
    }
}

extension OverviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.recentTransactions.count == 0 {
            return
        }
        
        let txDetailsVC = Storyboards.TransactionFullDetailsViewController.instantiateViewController(for: TransactionFullDetailsViewController.self)
        txDetailsVC.transaction = self.recentTransactions[indexPath.row]
        self.navigationController?.pushViewController(txDetailsVC, animated: true)
    }
}

extension OverviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        
        if self.recentTransactions.count != 0 {
            let tx = self.recentTransactions[indexPath.row]
            cell.setData(tx)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.recentTransactions.count > indexPath.row {
            if self.recentTransactions[indexPath.row].Animate {
                cell.blink()
            }
            self.recentTransactions[indexPath.row].Animate = false
        }
    }
}
