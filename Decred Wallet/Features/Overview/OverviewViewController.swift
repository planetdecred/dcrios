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
    @IBOutlet weak var pageSubtitleLabel: UILabel!
    
    var refreshControl: UIRefreshControl!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var usdBalanceLabel: UILabel!
    
    // MARK: Backup phrase section (Top view)
    @IBOutlet weak var seedBackupSectionView: UIView!
    @IBOutlet weak var walletsNeedBackupLabel: UILabel!
    
    // MARK: Account mixer prompt section (Top view)
    @IBOutlet weak var accountNeedMixingLabel: UILabel!
    @IBOutlet weak var accountMixingPromptSectionView: UIView!
    
    // MARK: Account mixer section (Top view)
    @IBOutlet weak var accountMixerSectionView: RoundedView!
    @IBOutlet weak var mixerRunnungLabel: UILabel!
    @IBOutlet weak var mixerRunningInfoLabel: UILabel!
    @IBOutlet weak var mixerTableView: UITableView!
    @IBOutlet weak var mixersTableViewHeightContraint: NSLayoutConstraint!
    
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
    @IBOutlet weak var singleWalletSyncDetailsViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var syncCurrentStepTitleLabel: UILabel!
    @IBOutlet weak var syncCurrentStepReportLabel: UILabel!
    @IBOutlet weak var syncCurrentStepProgressLabel: UILabel!
    @IBOutlet weak var peerCountLabel: UILabel!
    @IBOutlet weak var peerCountTitleLabel: UILabel!
    @IBOutlet weak var rescanWalletNameLabel: UILabel!
    
    // use following views to display sync progress details for multiple wallets
    @IBOutlet weak var multipleWalletsPeerCountLabel: UILabel!
    @IBOutlet weak var multipleWalletsPeerCountTitleLabel: UILabel!
    @IBOutlet weak var multipleWalletsSyncDetailsTableView: UITableView!
    @IBOutlet weak var multipleWalletsSyncDetailsTableViewHeightConstraint: NSLayoutConstraint!
    
    private var multiWallet = WalletLoader.shared.multiWallet!

    var hideSeedBackupPrompt: Bool = false
    var hideAccountMixingPrompt: Bool = false
    var recentTransactions = [Transaction]()
    var mixingAccounts = [MixerAcount]()
    var refreshBestBlockAgeTimer: Timer?
    
    var exchangeRate: NSDecimalNumber?
    var dcrAmountUnit: Bool = true
    var exchangeValue: NSDecimalNumber?
    var currencyConversionDisabled: Bool?
    
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
        
        WalletLoader.shared.multiWallet.setBlocksRescanProgressListener(self)
        
        WalletLoader.shared.multiWallet.setAccountMixerNotification(self)

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
        self.checkWhetherToPromptForAccountMixing()
        
        if !WalletLoader.shared.multiWallet.isSyncing() {
            self.refreshLatestBlockInfoPeriodically()
        }
        
        currencyConversionDisabled = Settings.currencyConversionOption == .None
        if !currencyConversionDisabled! {
            self.fetchExchangeRate()
        } else {
            usdBalanceLabel.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // stop refreshing best block age when view becomes invisible
        self.refreshBestBlockAgeTimer?.invalidate()
    }
    
    private func fetchExchangeRate() {
        switch Settings.currencyConversionOption {
        case .None:
            self.exchangeRate = nil
            break
            
        case .Bittrex:
            ExchangeRates.Bittrex.fetch(callback: self.displayExchangeRate)
        }
    }
    
    func displayExchangeRate(_ newExchangeRate: NSDecimalNumber?) {
        // only show error if an exchange rate has never been fetched previously
        if newExchangeRate == nil && self.exchangeRate == nil {
            return
        }
        
        self.exchangeRate = newExchangeRate ?? self.exchangeRate // maintain current value if new value is nil

        let dcrAmount = WalletLoader.shared.multiWallet.totalBalance
        let usdAmount = NSDecimalNumber(value: dcrAmount).multiplying(by: exchangeRate!)
        self.exchangeValue = usdAmount
        self.usdBalanceLabel.isHidden = false
        self.usdBalanceLabel.text = "$\(usdAmount.round(2).formattedWithSeparator)"
       
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
        
        //mixers tableview
        self.mixerTableView.delegate = self
        self.mixerTableView.dataSource = self
        
        //TODO change me
        self.mixersTableViewHeightContraint.constant = WalletMixerCell.height
        
        pageSubtitleLabel.layer.borderColor = UIColor.appColors.paleGray.cgColor
        pageSubtitleLabel.layer.borderWidth = 1.0
        pageSubtitleLabel.layer.cornerRadius = 8
        pageSubtitleLabel.isHidden = true
        
        usdBalanceLabel.layer.borderColor = UIColor.appColors.paleGray.cgColor
        usdBalanceLabel.layer.borderWidth = 1.0
        usdBalanceLabel.layer.cornerRadius = 8
        usdBalanceLabel.isHidden = true
    }
    
    @objc func refreshRecentActivityAndUpdateBalance() {
        self.refreshControl.beginRefreshing()
        self.updateMultiWalletBalance()
        self.updateRecentActivity()
        self.refreshControl.endRefreshing()
    }
    
    func updateMultiWalletBalance() {
        let totalWalletAmount = WalletLoader.shared.multiWallet.totalBalance
        let totalAmountRoundedOff = (Decimal(totalWalletAmount) as NSDecimalNumber).round(8)
        self.balanceLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: UIColor.appColors.darkBlue)
        self.setMixerStatus()
    }
    
    func updateRecentActivity() {
        // Fetch 3 most recent transactions
        guard let transactions = WalletLoader.shared.multiWallet.transactionHistory(offset: 0, count: 3),
            !transactions.isEmpty
            else {
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
        
        self.recentTransactionsTableViewHeightContraint.constant = TransactionTableViewCell.height() * CGFloat(self.recentTransactions.count)
        self.recentTransactionsTableView.reloadData()

        self.recentTransactionsTableView.isHidden = false
        self.showAllTransactionsButton.isHidden = false
        self.noTransactionsLabelView.superview?.isHidden = true
        self.setMixerStatus()
    }
    
    func updateWalletStatusIndicatorAndLabel() {
        let walletIsOnline = SyncManager.shared.isSynced || SyncManager.shared.isSyncing
        self.onlineStatusIndicator.backgroundColor = walletIsOnline ? UIColor.appColors.green : UIColor.appColors.orange
        self.onlineStatusLabel.text = walletIsOnline ? LocalizedStrings.online : LocalizedStrings.offline
    }
    
    func updateSyncStatusIndicatorAndLabel() {
        if SyncManager.shared.isRescanning {
            self.syncStatusImage.image = UIImage(named: "ic_syncing")
            self.syncStatusLabel.text = LocalizedStrings.rescanningBlocks
        } else if SyncManager.shared.isSynced {
            self.syncStatusImage.image = UIImage(named: "ic_checkmark_round")
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
    
    func toggleRescanProgressViews(isRescanning: Bool) {
        self.latestBlockLabel.superview?.isHidden = isRescanning
        self.generalSyncProgressViews.isHidden = !isRescanning
        self.showSyncDetailsButton.isHidden = !isRescanning
        
        // show single wallet sync details view section for rescanning
        if isRescanning {
            self.singleWalletSyncDetailsView.isHidden = false
            self.multipleWalletsPeerCountLabel.superview?.isHidden = false
            self.multipleWalletsSyncDetailsTableView?.isHidden = true
            
        } else {
            // hide rescan details section if rescan is not ongoing
            // but don't change the visibility state if rescan is ongoing.
            self.syncDetailsSection.isHidden = true
        }
    }

    func updateSyncConnectionButtonTextAndIcon() {
        if SyncManager.shared.isSyncing || SyncManager.shared.isRescanning {
            self.syncConnectionButton.setTitle(LocalizedStrings.cancel, for: .normal)
            self.syncConnectionButton.setImage(nil, for: .normal)
        } else if SyncManager.shared.isSynced {
            self.syncConnectionButton.setTitle(LocalizedStrings.disconnect, for: .normal)
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
        MultiWalletSyncDetailsLoader.setup(for: self.multipleWalletsSyncDetailsTableView)
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
    
    func checkWhetherToPromptForAccountMixing() {
        if !WalletLoader.shared.multiWallet.readBoolConfigValue(forKey: "has_setup_privacy", defaultValue: false) && !self.hideAccountMixingPrompt {
            self.accountMixingPromptSectionView.isHidden = false
        }
    }
    //TODO fix me when get mixer Wallet
    func setMixerStatus() {
        var activeMixers = 0
        var WalletID = 0
        self.mixingAccounts.removeAll()
        for wallet in WalletLoader.shared.wallets {
            if wallet.isAccountMixerActive() {
                activeMixers += 1
                WalletID = wallet.id_
                 let wallet  = WalletLoader.shared.multiWallet.wallet(withID: WalletID)
                 if let unmixedAccountNumber = wallet?.readInt32ConfigValue(forKey: Dcrlibwallet.DcrlibwalletAccountMixerUnmixedAccount, defaultValue: -1) {
                     do {
                        if let balance  =  try wallet?.getAccountBalance(unmixedAccountNumber) {
                            let mxAccount = MixerAcount(name: wallet?.name, balance: "\(balance.dcrTotal) DCR")
                            self.mixingAccounts.append(mxAccount)
                        }
                        
                     } catch {
                         DispatchQueue.main.async {
                             Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
                         }
                     }
                 }
            }
        }
        
        if (activeMixers > 0) {
            DispatchQueue.main.async {
                self.mixerRunnungLabel.text = activeMixers > 1 ? "\(activeMixers) \(LocalizedStrings.mixersAreRuning)" : LocalizedStrings.mixerIsRuning
                self.accountMixerSectionView.isHidden = false
                self.mixersTableViewHeightContraint.constant = WalletMixerCell.height * CGFloat(activeMixers)
                self.mixerTableView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.accountMixerSectionView.isHidden = true
            }
        }
    }
    
    @IBAction func dismissSeedBackupPromptTapped(_ sender: Any) {
        self.hideSeedBackupPrompt = true
        self.seedBackupSectionView.isHidden = true
        SimpleAlertDialog.show(sender: self, message: LocalizedStrings.backUpYourWalletsReminder, okButtonText: LocalizedStrings.gotIt, callback: nil)
    }
    
    @IBAction func setupAccountMixingTapped(_ sender: Any) {
        if let walletsTabIndex = NavigationMenuTabBarController.tabItems.firstIndex(of: .wallets) {
            WalletLoader.shared.multiWallet.setBoolConfigValueForKey(GlobalConstants.Strings.SHOWN_PRIVACY_TOOLTIP, value: false)
            NavigationMenuTabBarController.instance?.navigateToTab(index: walletsTabIndex)
        }
    }
    
    @IBAction func dismissAccountMixingPromptTapped(_ sender: Any) {
        self.hideAccountMixingPrompt = true
        self.accountMixingPromptSectionView.isHidden = true
    }
    
    @IBAction func seedBackupTapped(_ sender: Any) {
        self.goToWalletPage()
    }
    
    @IBAction func mixerArrowTapped(_ sender: Any) {
        self.goToWalletPage()
    }
    
    func goToWalletPage() {
        if let walletsTabIndex = NavigationMenuTabBarController.tabItems.firstIndex(of: .wallets) {
            NavigationMenuTabBarController.instance?.navigateToTab(index: walletsTabIndex)
        }
    }
    
    @IBAction func showAllTransactionsTap(_ sender: Any) {
        if let txHistoryTabIndex = NavigationMenuTabBarController.tabItems.firstIndex(of: .transactions) {
            NavigationMenuTabBarController.instance?.navigateToTab(index: txHistoryTabIndex)
        }
    }

    // Handle action of rescan, sync connect/reconnect/cancel button click based on sync/network status
    @IBAction func syncConnectionButtonTap(_ sender: Any) {
        if SyncManager.shared.isRescanning {
            DispatchQueue.global(qos: .userInitiated).async {
                WalletLoader.shared.multiWallet.cancelRescan()
            }
        } else if SyncManager.shared.isSynced || SyncManager.shared.isSyncing {
             DispatchQueue.global(qos: .userInitiated).async {
                WalletLoader.shared.multiWallet.cancelSync()
            }
        } else {
            SyncManager.shared.startSync(allowSyncOnCellular: Settings.syncOnCellular)
        }
        DispatchQueue.main.async {
            self.updateSyncConnectionButtonTextAndIcon()
        }
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
        self.updatePageSubtitleTextOnScroll(using: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updatePageTitleTextOnScroll(using: scrollView)
        self.updatePageSubtitleTextOnScroll(using: scrollView)
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
    
    func updatePageSubtitleTextOnScroll(using scrollView: UIScrollView) {
        // We are targeting only the parent scroll view because this VC also holds a tableview that can be scrolled
        // and we do not want to react to that.
        guard scrollView == self.parentScrollView else { return }

        if scrollView.contentOffset.y < self.balanceLabel.frame.height / 2 {
            self.pageSubtitleLabel.isHidden = true
        } else {
            if !currencyConversionDisabled! {
                self.pageSubtitleLabel.attributedText = self.usdBalanceLabel.attributedText!
                self.pageSubtitleLabel.isHidden = false
            }
        }
    }
}

// extension methods for recent activity tableview delegate and datasource.
extension OverviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.mixerTableView {
            return WalletMixerCell.height
        }
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.mixerTableView {
            return self.mixingAccounts.count
        }
        return self.recentTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.mixerTableView {
            let cell = self.mixerTableView.dequeueReusableCell(withIdentifier: WalletMixerCell.walletMixerIdentifier) as! WalletMixerCell
            let mx = self.mixingAccounts[indexPath.row]
            cell.render(mx.name!, balance: mx.balance!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier) as! TransactionTableViewCell
        let tx = self.recentTransactions[indexPath.row]
        cell.displayInfo(for: tx, hideWalletLabel: multiWallet.loadedWalletsCount() == 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.mixerTableView {
            return
        }
        
        if self.recentTransactions[indexPath.row].animate {
            cell.blink()
        }
        self.recentTransactions[indexPath.row].animate = false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.mixerTableView {
            return
        }
        let txDetailsVC = TransactionDetailsViewController.instantiate(from: .TransactionDetails)
        txDetailsVC.transaction = self.recentTransactions[indexPath.row]
        self.present(txDetailsVC, animated: true)
    }
}

extension OverviewViewController: DcrlibwalletSyncProgressListenerProtocol {
    func onCFiltersFetchProgress(_ cfiltersFetchProgress: DcrlibwalletCFiltersFetchProgressReport?) {
        guard let report = cfiltersFetchProgress else { return }
        DispatchQueue.main.async {
            self.syncStatusLabel.text = LocalizedStrings.synchronizing
            self.displayGeneralSyncProgress(report.generalSyncProgress)
            
            self.syncCurrentStepNumberLabel.text = LocalizedStrings.stepCfilter
            self.syncCurrentStepSummaryLabel.text = String(format: LocalizedStrings.fetchingCfilter, report.cFiltersFetchProgress)
            
            self.syncCurrentStepTitleLabel.text = LocalizedStrings.cfilterFetched
            self.syncCurrentStepReportLabel.text = String(format: LocalizedStrings.cfilterFetchedTotal, report.currentCFilterHeight, report.totalCFiltersToFetch)
            
            self.syncCurrentStepProgressLabel.text = report.blockRemaining
            
        }
    }
    
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
            
            self.syncCurrentStepNumberLabel.text = String(format: LocalizedStrings.syncSteps, 3)
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
            self.setMixerStatus()
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
    
    func clearGeneralSyncProgress() {
        self.totalSyncProgressView.progress = 0.0
        self.totalSyncProgressPercentageLabel.text = ""
        self.totalSyncETALabel.text = ""
    }
    
    func updateUI(syncCompletedSuccessfully synced: Bool) {
        self.clearGeneralSyncProgress()
        self.updateWalletStatusIndicatorAndLabel()
        self.updateSyncStatusIndicatorAndLabel()
        self.updateSyncConnectionButtonTextAndIcon()
        print("update UI set meixer status")
        self.setMixerStatus()
        self.toggleSyncProgressViews(isSyncing: false)
        self.displayLatestBlockHeightAndAge()
        self.refreshLatestBlockInfoPeriodically()
        self.displayConnectedPeersCount()
        self.clearAndHideSyncDetails()
        
        if synced {
            self.updateMultiWalletBalance()
            self.updateRecentActivity()
        }
    }
    
    func refreshLatestBlockInfoPeriodically() {
        self.refreshBestBlockAgeTimer?.invalidate()
        self.refreshBestBlockAgeTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {_ in
            DispatchQueue.main.async {
                self.displayLatestBlockHeightAndAge()
            }
        }
    }
}

extension OverviewViewController: DcrlibwalletBlocksRescanProgressListenerProtocol {
    func onBlocksRescanStarted(_ walletID: Int) {
        DispatchQueue.main.async {
            self.updateWalletStatusIndicatorAndLabel()
            self.updateSyncStatusIndicatorAndLabel()
            self.updateSyncConnectionButtonTextAndIcon()
            self.toggleRescanProgressViews(isRescanning: true)
            self.clearAndHideSyncDetails()
            self.toggleSingleWalletSyncDetailsViewHeight(isRescanning: true)
            self.multipleWalletsPeerCountLabel.superview?.isHidden = true
            
            let nOpenedWallets = WalletLoader.shared.multiWallet.openedWalletsCount()
            if nOpenedWallets > 1 {
                let wallet = WalletLoader.shared.multiWallet.wallet(withID: walletID)
                self.rescanWalletNameLabel.superview?.isHidden = false
                self.rescanWalletNameLabel.text = wallet?.name
            } else {
                self.rescanWalletNameLabel.superview?.isHidden = true
            }
        }
    }
    
    func onBlocksRescanProgress(_ p0: DcrlibwalletHeadersRescanProgressReport?) {
        guard let report = p0 else { return }
        
        DispatchQueue.main.async {
            self.syncStatusLabel.text = LocalizedStrings.rescanningBlocks
            self.displayGeneralSyncProgress(report.generalSyncProgress)
            
            self.syncCurrentStepNumberLabel.text = LocalizedStrings.connectedPeersCount
            self.syncCurrentStepSummaryLabel.text = "\(WalletLoader.shared.multiWallet.connectedPeers())"
            
            self.syncCurrentStepTitleLabel.text = LocalizedStrings.scannedBlocks
            self.syncCurrentStepReportLabel.text = "\(report.currentRescanHeight)"
            
            self.syncCurrentStepProgressLabel.text = String(format: LocalizedStrings.blocksLeft, report.totalHeadersToScan - report.currentRescanHeight)
        }
    }
    
    func onBlocksRescanEnded(_ walletID: Int, err: Error?) {
        DispatchQueue.main.async {
            self.toggleSingleWalletSyncDetailsViewHeight(isRescanning: false)
            self.rescanWalletNameLabel.superview?.isHidden = true
            self.multipleWalletsPeerCountLabel.superview?.isHidden = false
            self.updateUI(syncCompletedSuccessfully: err == nil)
        }
    }
    
    // Reduce the height of sync Details view onRescan to cover up empty space
    func toggleSingleWalletSyncDetailsViewHeight(isRescanning: Bool) {
        self.peerCountLabel.isHidden = isRescanning
        self.peerCountTitleLabel.isHidden = isRescanning
        self.singleWalletSyncDetailsViewHeightConst.constant = isRescanning ? 88.5 : 125
    }
}

extension OverviewViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
        let unconfirmedTransactions = self.recentTransactions.filter {$0.confirmations <= 2}.count
        if unconfirmedTransactions > 0 {
            DispatchQueue.main.async {
                self.updateRecentActivity()
            }
        }
    }
    
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.recentTransactions.contains(where: { $0.hash == tx.hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.animate = true
        self.recentTransactions.insert(tx, at: 0)
        if self.recentTransactions.count > 3 {
            _ = self.recentTransactions.popLast()
        }
        
        DispatchQueue.main.async {
            self.recentTransactionsTableViewHeightContraint.constant = TransactionTableViewCell.height() * CGFloat(self.recentTransactions.count)
            self.updateMultiWalletBalance()
            self.recentTransactionsTableView.reloadData()
            self.setMixerStatus()
        }
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
        DispatchQueue.main.async {
            self.updateMultiWalletBalance()
            self.updateRecentActivity()
        }
    }
}

extension OverviewViewController: DcrlibwalletAccountMixerNotificationListenerProtocol {
    func onAccountMixerEnded(_ walletID: Int) {
        print("mixer ended")
        DispatchQueue.main.async {
            self.setMixerStatus()
            Utils.showBanner(in: self.view, type: .error, text: "mixer has stopped running")
        }
    }
    
    func onAccountMixerStarted(_ walletID: Int) {
        print("mixer started")
        DispatchQueue.main.async {
            self.setMixerStatus()
        }
    }
}
