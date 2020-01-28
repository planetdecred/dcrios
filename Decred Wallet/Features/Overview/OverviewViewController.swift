//
//  OverviewViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class OverviewViewController: UIViewController {
    // Custom navigation bar
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var pageTitleSeparator: UIView!
    
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    // MARK: Backup phrase section (Top view)
    @IBOutlet weak var seedBackupSectionView: UIView!
    @IBOutlet weak var walletsNeedBackupLabel: UILabel!
    
    // MARK: Recent activity section
    @IBOutlet weak var noTransactionsLabelView: UILabel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var recentTransactionsTableViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var showAllTransactionsButton: UIButton!
    
    // MARK: Sync status section
    @IBOutlet weak var onlineStatusIndicator: UIView!
    @IBOutlet weak var onlineStatusLabel: UILabel!
    
    @IBOutlet weak var syncStatusImage: UIImageView!
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var syncConnectionButton: UIButton!
    
    @IBOutlet weak var latestBlockLabel: UILabel!
    @IBOutlet weak var connectedPeersLabel: UILabel!
    
    @IBOutlet weak var generalSyncProgressViews: UIStackView!
    @IBOutlet weak var totalSyncProgressView: UIProgressView!
    @IBOutlet weak var totalSyncProgressPercentageLabel: UILabel!
    @IBOutlet weak var totalSyncETALabel: UILabel!
    
    @IBOutlet weak var showSyncDetailsButton: UIButton!
    
    @IBOutlet weak var syncDetailsSection: UIStackView!
    @IBOutlet weak var syncCurrentStepNumberLabel: UILabel!
    @IBOutlet weak var syncCurrentStepSummaryLabel: UILabel!
    
    // display and update following views if only 1 wallet is being synced
    @IBOutlet weak var singleWalletSyncDetailsView: RoundedView!
    @IBOutlet weak var syncCurrentStepTitleLabel: UILabel!
    @IBOutlet weak var syncCurrentStepReportLabel: UILabel!
    @IBOutlet weak var syncCurrentStepProgressLabel: UILabel!
    @IBOutlet weak var peerCountLabel: UILabel!
    
    // use following views to display sync progress details for multiple wallets
    @IBOutlet weak var multipleWalletsPeerCountLabel: UILabel!
    @IBOutlet weak var multipleWalletsSyncDetailsTableView: UITableView!
    @IBOutlet weak var multipleWalletsSyncDetailsTableViewHeightConstraint: NSLayoutConstraint!

    var hideSeedBackupPrompt: Bool = false
    var recentTransactions = [Transaction]()
    var refreshBestBlockAgeTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeViews()
        
        self.updateWalletStatusIndicatorAndLabel()
        self.updateSyncStatusIndicatorAndLabel()
        self.updateSyncConnectionButtonTextAndIcon()
        self.toggleSyncProgressViews(isSyncing: SyncManager.shared.isSyncing)
        self.clearAndHideSyncDetails()
        
        // Register sync progress listener.
        // If sync is currently ongoing, this listener will immediately receive the current/latest
        // sync progress report which will then be displayed on the UI.
        // If sync is not ongoing, registering this listener enables us to get notified when a peer
        // is connected or disconnected, so we can update the peer count label appropriately.
        let syncProgressListener = self as DcrlibwalletSyncProgressListenerProtocol
        try? WalletLoader.shared.multiWallet.add(syncProgressListener, uniqueIdentifier: "\(self)")
        
        // Register tx notification listener to update recent activity table for new txs.
        let txNotificationListener = self as DcrlibwalletTxAndBlockNotificationListenerProtocol
        try? WalletLoader.shared.multiWallet.add(txNotificationListener, uniqueIdentifier: "\(self)")

        // Display latest block and connected peer count if there's no ongoing sync.
        if !SyncManager.shared.isSyncing {
            self.displayLatestBlockHeightAndAge()
            self.displayConnectedPeersCount()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.refreshRecentActivityAndUpdateBalance()
        self.checkWhetherToPromptForSeedBackup()
        
        if !WalletLoader.shared.multiWallet.isSyncing() {
            self.refreshLatestBlockInfoPeriodically()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // stop refreshing best block age when view becomes invisible
        self.refreshBestBlockAgeTimer?.invalidate()
    }
    
    func initializeViews() {
        // Set a scroll listener delegate so we can update the nav bar page title text on user scroll.
        self.parentScrollView.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refreshRecentActivityAndUpdateBalance), for: .valueChanged)
        self.parentScrollView.addSubview(self.refreshControl)
       
        self.recentTransactionsTableView.registerCellNib(TransactionTableViewCell.self)
        self.recentTransactionsTableView.delegate = self
        self.recentTransactionsTableView.dataSource = self

        self.totalSyncProgressView.layer.cornerRadius = 8
        self.showSyncDetailsButton.addBorder(atPosition: .top, color: UIColor.appColors.gray, thickness: 0.62)
        self.syncDetailsSection.horizontalBorder(borderColor: UIColor.appColors.gray, yPosition: 0, borderHeight: 0.62)
    
        MultiWalletSyncDetailsLoader.setup(for: self.multipleWalletsSyncDetailsTableView)
    }
    
    @objc func refreshRecentActivityAndUpdateBalance() {
        self.refreshControl.beginRefreshing()
        self.updateMultiWalletBalance()
        self.updateRecentActivity()
        self.refreshControl.endRefreshing()
    }
    
    func updateMultiWalletBalance() {
        let totalWalletAmount = WalletLoader.shared.multiWallet.totalBalance()
        let totalAmountRoundedOff = (Decimal(totalWalletAmount) as NSDecimalNumber).round(8)
        self.balanceLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: UIColor.appColors.darkBlue)
    }
    
    func updateRecentActivity() {
        // Fetch 3 most recent transactions
        // todo this should be a multiwallet fetch rather than a wallet fetch!
        guard let transactions = WalletLoader.shared.firstWallet?.transactionHistory(offset: 0, count: 3) else {
            self.recentTransactionsTableView.isHidden = true
            self.showAllTransactionsButton.isHidden = true
            self.noTransactionsLabelView.superview?.isHidden = false
            return
        }
        
        if transactions.count == 0 {
            self.recentTransactionsTableView.isHidden = true
            self.showAllTransactionsButton.isHidden = true
            self.noTransactionsLabelView.superview?.isHidden = false
            return
        }
        
        self.recentTransactions = transactions
        self.recentTransactionsTableView.reloadData()
        
        self.recentTransactionsTableViewHeightContraint.constant = TransactionTableViewCell.height() * CGFloat(self.recentTransactions.count)

        self.recentTransactionsTableView.isHidden = false
        self.showAllTransactionsButton.isHidden = false
        self.noTransactionsLabelView.superview?.isHidden = true
    }
    
    func updateWalletStatusIndicatorAndLabel() {
        let walletIsOnline = SyncManager.shared.isSynced || SyncManager.shared.isSyncing
        self.onlineStatusIndicator.backgroundColor = walletIsOnline ? UIColor.appColors.green : UIColor.appColors.orange
        self.onlineStatusLabel.text = walletIsOnline ? LocalizedStrings.online : LocalizedStrings.offline
    }
    
    func updateSyncStatusIndicatorAndLabel() {
        if SyncManager.shared.isSynced {
            self.syncStatusImage.image = UIImage(named: "ic_checkmark")
            self.syncStatusLabel.text = LocalizedStrings.walletSynced
        } else if SyncManager.shared.isSyncing {
            self.syncStatusImage.image = UIImage(named: "ic_syncing")
            self.syncStatusLabel.text = LocalizedStrings.synchronizing
        } else {
            self.syncStatusImage.image = UIImage(named: "ic_crossmark")
            self.syncStatusLabel.text = LocalizedStrings.walletNotSynced
        }
    }

    func toggleSyncProgressViews(isSyncing: Bool) {
        self.latestBlockLabel.superview?.isHidden = isSyncing
        self.generalSyncProgressViews.isHidden = !isSyncing
        self.showSyncDetailsButton.isHidden = !isSyncing

        // show appropriate view section depending on how many wallets are being synced
        if isSyncing {
            let nOpenedWallets = WalletLoader.shared.multiWallet.openedWalletsCount()
            let isMultipleWalletsSync = nOpenedWallets > 1
            
            if isMultipleWalletsSync {
                self.multipleWalletsSyncDetailsTableViewHeightConstraint.constant = CGFloat(nOpenedWallets) * self.multipleWalletsSyncDetailsTableView.rowHeight
            }
            
            self.singleWalletSyncDetailsView.isHidden = isMultipleWalletsSync
            self.multipleWalletsPeerCountLabel.superview?.isHidden = !isMultipleWalletsSync
            self.multipleWalletsSyncDetailsTableView?.isHidden = !isMultipleWalletsSync
            
        } else {
            // hide sync details section if sync is not ongoing
            // but don't change the visibility state if sync is ongoing.
            self.syncDetailsSection.isHidden = true
        }
    }

    func updateSyncConnectionButtonTextAndIcon() {
        if SyncManager.shared.isSynced {
            self.syncConnectionButton.setTitle(LocalizedStrings.disconnect, for: .normal)
            self.syncConnectionButton.setImage(nil, for: .normal)
        } else if SyncManager.shared.isSyncing {
            self.syncConnectionButton.setTitle(LocalizedStrings.cancel, for: .normal)
            self.syncConnectionButton.setImage(nil, for: .normal)
        } else {
            self.syncConnectionButton.setTitle(LocalizedStrings.reconnect, for: .normal)
            self.syncConnectionButton.setImage(UIImage(named: "ic_rescan"), for: .normal)
            self.syncConnectionButton.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    private func clearAndHideSyncDetails() {
        self.syncDetailsSection.isHidden = true
        self.showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
        
        self.syncCurrentStepNumberLabel.text = String(format: LocalizedStrings.syncSteps, 0)
        self.syncCurrentStepSummaryLabel.text = ""

        self.syncCurrentStepTitleLabel.text = ""
        self.syncCurrentStepReportLabel.text = ""
        self.syncCurrentStepProgressLabel.text = ""
        self.peerCountLabel.text = "\(WalletLoader.shared.multiWallet.connectedPeers())"
        self.multipleWalletsPeerCountLabel.text = "\(WalletLoader.shared.multiWallet.connectedPeers())"
    }
    
    private func displayLatestBlockHeightAndAge() {
        guard let bestBlockInfo = WalletLoader.shared.multiWallet.getBestBlock() else { return }
        
        let bestBlockHeight = bestBlockInfo.height
        let bestBlockAge = Int64(Date().timeIntervalSince1970) - bestBlockInfo.timestamp
        let bestBlockAgeAsTimeAgo = Utils.timeAgo(timeInterval: bestBlockAge)
        
        let latestBlockText = String(format: LocalizedStrings.latestBlockAge, bestBlockHeight, bestBlockAgeAsTimeAgo)

        let bestBlockHeightRange = (latestBlockText as NSString).range(of: "\(bestBlockHeight)")
        let bestBlockAgeRange = (latestBlockText as NSString).range(of: bestBlockAgeAsTimeAgo)
        
        let attributedString = NSMutableAttributedString(string: latestBlockText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: UIColor.appColors.darkBlue,
                                      range: bestBlockHeightRange)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: UIColor.appColors.darkBlue,
                                      range: bestBlockAgeRange)
        
        self.latestBlockLabel.attributedText = attributedString
    }
    
    private func displayConnectedPeersCount() {
        let peerCount = WalletLoader.shared.multiWallet.connectedPeers()
        if peerCount == 0 {
            self.connectedPeersLabel.attributedText = NSMutableAttributedString(string: LocalizedStrings.noConnectedPeer)
            return
        }
        
        let connectedPeerText = String(format: LocalizedStrings.connectedTo, peerCount)
        let peerCountRange = (connectedPeerText as NSString).range(of: "\(peerCount)")
        
        let attributedString = NSMutableAttributedString(string: connectedPeerText)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: UIColor.appColors.darkBlue,
                                      range: peerCountRange)
        
        self.connectedPeersLabel.attributedText = attributedString
    }
    
    func checkWhetherToPromptForSeedBackup() {
        let numWalletsNeedingSeedBackup = WalletLoader.shared.multiWallet.numWalletsNeedingSeedBackup()
        if self.hideSeedBackupPrompt || numWalletsNeedingSeedBackup == 0 {
            self.seedBackupSectionView.isHidden = true
            return
        }
        
        self.seedBackupSectionView.isHidden = false
        if numWalletsNeedingSeedBackup == 1 {
            self.walletsNeedBackupLabel.text = LocalizedStrings.oneWalletNeedBackup
        } else {
            self.walletsNeedBackupLabel.text = String(format: LocalizedStrings.walletsNeedBackup,
                                                      numWalletsNeedingSeedBackup)
        }
    }
    
    @IBAction func dismissSeedBackupPromptTapped(_ sender: Any) {
        self.hideSeedBackupPrompt = true
        self.seedBackupSectionView.isHidden = true
    }
    
    @IBAction func seedBackupTapped(_ sender: Any) {
        if let walletsTabIndex = NavigationMenuTabBarController.tabItems.firstIndex(of: .wallets) {
            NavigationMenuTabBarController.instance?.navigateToTab(index: walletsTabIndex)
        }
    }
    
    @IBAction func showAllTransactionsTap(_ sender: Any) {
        if let txHistoryTabIndex = NavigationMenuTabBarController.tabItems.firstIndex(of: .transactions) {
            NavigationMenuTabBarController.instance?.navigateToTab(index: txHistoryTabIndex)
        }
    }

    // Handle action of sync connect/reconnect/cancel button click based on sync/network status
    @IBAction func syncConnectionButtonTap(_ sender: Any) {
        if SyncManager.shared.isSynced || SyncManager.shared.isSyncing {
            WalletLoader.shared.multiWallet.cancelSync()
        } else {
            SyncManager.shared.startSync(allowSyncOnCellular: Settings.syncOnCellular)
        }
        
        self.updateSyncConnectionButtonTextAndIcon()
    }
        
    @IBAction func showOrHideSyncDetails(_ sender: Any) {
        self.syncDetailsSection.isHidden = !self.syncDetailsSection.isHidden
        if self.syncDetailsSection.isHidden {
            self.showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
        } else {
            self.showSyncDetailsButton.setTitle(LocalizedStrings.hideDetails, for: .normal)
        }
    }
}

// extension methods for parent scrollview delegate so we can update
// the nav bar page title text on user scroll.
extension OverviewViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updatePageTitleTextOnScroll(using: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updatePageTitleTextOnScroll(using: scrollView)
    }

    func updatePageTitleTextOnScroll(using scrollView: UIScrollView) {
        // We are targeting only the parent scroll view because this VC also holds a tableview that can be scrolled
        // and we do not want to react to that.
        guard scrollView == self.parentScrollView else { return }

        if scrollView.contentOffset.y < self.balanceLabel.frame.height / 2 {
            self.pageTitleLabel.text = LocalizedStrings.overview
            self.pageTitleSeparator.isHidden = true
        } else {
            self.pageTitleLabel.attributedText = self.balanceLabel.attributedText!
            self.pageTitleSeparator.isHidden = false
        }
    }
}

// extension methods for recent activity tableview delegate and datasource.
extension OverviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        let tx = self.recentTransactions[indexPath.row]
        cell.setData(tx)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.recentTransactions[indexPath.row].animate {
            cell.blink()
        }
        self.recentTransactions[indexPath.row].animate = false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let txDetailsVC = TransactionDetailsViewController.instantiate(from: .TransactionDetails)
        txDetailsVC.transaction = self.recentTransactions[indexPath.row]
        self.present(txDetailsVC, animated: true)
    }
}

extension OverviewViewController: DcrlibwalletSyncProgressListenerProtocol {
    func onSyncStarted(_ wasRestarted: Bool) {
        DispatchQueue.main.async {
            self.updateWalletStatusIndicatorAndLabel()
            self.updateSyncStatusIndicatorAndLabel()
            self.updateSyncConnectionButtonTextAndIcon()
            self.toggleSyncProgressViews(isSyncing: true)
            self.clearAndHideSyncDetails()
            
            if wasRestarted {
                self.syncStatusLabel.text = LocalizedStrings.restartingSync
            }
        }
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        DispatchQueue.main.async {
            if WalletLoader.shared.multiWallet.isSyncing() {
                self.peerCountLabel.text = "\(numberOfConnectedPeers)"
                self.multipleWalletsPeerCountLabel.text = "\(numberOfConnectedPeers)"
            } else {
                self.displayConnectedPeersCount()
            }
        }
    }
    
    func onHeadersFetchProgress(_ headersFetchProgress: DcrlibwalletHeadersFetchProgressReport?) {
        guard let report = headersFetchProgress else { return }
        
        DispatchQueue.main.async {
            self.syncStatusLabel.text = LocalizedStrings.synchronizing
            self.displayGeneralSyncProgress(report.generalSyncProgress)
            
            self.syncCurrentStepNumberLabel.text = String(format: LocalizedStrings.syncSteps, 1)
            self.syncCurrentStepSummaryLabel.text = String(format: LocalizedStrings.headersFetchProgress, report.headersFetchProgress)
            
            self.syncCurrentStepTitleLabel.text = LocalizedStrings.blockHeadersFetched
            self.syncCurrentStepReportLabel.text = String(format: LocalizedStrings.fetchedHeaders, report.currentHeaderHeight, report.totalHeadersToFetch)
            
            self.syncCurrentStepProgressLabel.text = String(format: LocalizedStrings.bestBlockAgebehind, report.bestBlockAge)
        }
    }
    
    func onAddressDiscoveryProgress(_ addressDiscoveryProgress: DcrlibwalletAddressDiscoveryProgressReport?) {
        guard let report = addressDiscoveryProgress else { return }
        
        DispatchQueue.main.async {
            self.syncStatusLabel.text = LocalizedStrings.synchronizing
            self.displayGeneralSyncProgress(report.generalSyncProgress)
            
            self.syncCurrentStepNumberLabel.text = String(format: LocalizedStrings.syncSteps, 2)
            self.syncCurrentStepSummaryLabel.text = "\(LocalizedStrings.discoveringUsedAddresses) \(report.addressDiscoveryProgress)%"
            
            self.syncCurrentStepTitleLabel.text = LocalizedStrings.discoveringUsedAddresses
            self.syncCurrentStepReportLabel.text = ""
            
            var reportFormat = LocalizedStrings.addressDiscoveryProgressThrough
            if report.addressDiscoveryProgress > 100 {
                reportFormat = LocalizedStrings.addressDiscoveryProgressOver
            }
            self.syncCurrentStepProgressLabel.text = String(format: reportFormat, report.addressDiscoveryProgress)
        }
    }
    
    func onHeadersRescanProgress(_ headersRescanProgress: DcrlibwalletHeadersRescanProgressReport?) {
        guard let report = headersRescanProgress else { return }
        
        DispatchQueue.main.async {
            self.syncStatusLabel.text = LocalizedStrings.synchronizing
            self.displayGeneralSyncProgress(report.generalSyncProgress)
            
            self.syncCurrentStepNumberLabel.text = String(format: LocalizedStrings.syncSteps, 1)
            self.syncCurrentStepSummaryLabel.text = String(format: LocalizedStrings.headersScannedProgress, report.rescanProgress)
            
            self.syncCurrentStepTitleLabel.text = LocalizedStrings.blockHeaderScanned
            self.syncCurrentStepReportLabel.text = String(format: LocalizedStrings.scanningTotalHeaders, report.currentRescanHeight, report.totalHeadersToScan)
            
            self.syncCurrentStepProgressLabel.text = "\(report.rescanProgress)%"
        }
    }
    
    func onSyncCanceled(_ willRestart: Bool) {
        DispatchQueue.main.async {
            self.updateUI(syncCompletedSuccessfully: false)
        }
    }
    
    func onSyncCompleted() {
        DispatchQueue.main.async {
            self.updateUI(syncCompletedSuccessfully: true)
        }
    }
    
    func onSyncEndedWithError(_ err: Error?) {
        DispatchQueue.main.async {
            self.updateUI(syncCompletedSuccessfully: false)
        }
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo?) {
        DispatchQueue.main.async {
        }
    }
    
    func displayGeneralSyncProgress(_ progressReport: DcrlibwalletGeneralSyncProgress?) {
        guard let report = progressReport else { return }
        
        self.totalSyncProgressView.progress = Float(report.totalSyncProgress) / 100.0
        self.totalSyncProgressPercentageLabel.text = String(format: LocalizedStrings.syncProgressComplete, report.totalSyncProgress)
        self.totalSyncETALabel.text = String(format: LocalizedStrings.syncTimeLeft, report.totalTimeRemaining)
    }
    
    func updateUI(syncCompletedSuccessfully synced: Bool) {
        self.updateWalletStatusIndicatorAndLabel()
        self.updateSyncStatusIndicatorAndLabel()
        self.updateSyncConnectionButtonTextAndIcon()
        self.toggleSyncProgressViews(isSyncing: false)
        self.displayLatestBlockHeightAndAge()
        self.refreshLatestBlockInfoPeriodically()
        self.clearAndHideSyncDetails()
        
        if synced {
            self.updateMultiWalletBalance()
            self.updateRecentActivity()
        }
    }
    
    func refreshLatestBlockInfoPeriodically() {
        self.refreshBestBlockAgeTimer?.invalidate()
        self.refreshBestBlockAgeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            DispatchQueue.main.async {
                self.displayLatestBlockHeightAndAge()
            }
        }
    }
}

extension OverviewViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
        // not relevant to this VC
    }
    
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.recentTransactions.contains(where: { $0.hash == tx.hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.animate = true
        self.recentTransactions.insert(tx, at: 0)
        self.updateMultiWalletBalance()
        
        DispatchQueue.main.async {
            if self.recentTransactions.count > 3 {
                _ = self.recentTransactions.popLast()
            }
            self.recentTransactionsTableView.reloadData()
        }
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
        DispatchQueue.main.async {
            self.updateMultiWalletBalance()
            self.recentTransactionsTableView.reloadData()
        }
    }
}
