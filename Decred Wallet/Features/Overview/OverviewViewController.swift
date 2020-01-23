//
//  OverviewViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import Signals

class OverviewViewController: UIViewController {
    // Custom navigation bar
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var pageTitleSeparator: UIView!
    
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    // MARK: Backup phrase section (Top view)
    @IBOutlet weak var seedBackupSectionView: UIView!
    
    // MARK: Recent activity section
    @IBOutlet weak var noTransactionsLabelView: UILabel!
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var recentTransactionsTableViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var showAllTransactionsButton: UIButton!
    
    // MARK: Sync status section
    @IBOutlet weak var syncStatusSection: UIStackView!
    @IBOutlet weak var walletStatusLabelView: UIView!
    @IBOutlet weak var onlineStatusIndicator: UIView!
    @IBOutlet weak var onlineStatusLabel: UILabel!

    @IBOutlet weak var syncProgressView: UIView!
    @IBOutlet weak var syncStatusImage: UIImageView!
    @IBOutlet weak var syncStatusLabel: UILabel! {
        didSet {
            self.syncStatusLabel.text = (AppDelegate.walletLoader.isSynced == true) ? LocalizedStrings.walletSynced : LocalizedStrings.walletNotSynced
        }
    }
    @IBOutlet weak var latestBlockLabel: UILabel!
    @IBOutlet weak var connectedPeersLabel: UILabel!
    
    @IBOutlet weak var showSyncDetailsButton: UIButton! {
        didSet { self.showSyncDetailsButton.isHidden = (AppDelegate.walletLoader.multiWallet.isSyncing() == true) ? true : false; self.showSyncDetailsButton.clipsToBounds = true; }
    }
    
    @IBOutlet weak var syncConnectionButton: UIButton!

    var refreshBestBlockAgeTimer: Timer?
    // Container for our progress report bar & text.
    let syncProgressBarContainer = UIView(frame: CGRect.zero)
    
    /*
        Data Values
    */
    var recentTransactions = [Transaction]()
    var syncManager = SyncManager.shared // Created as singleton to have just one listener instance
    
    var syncToggle: Bool = false {
        didSet {
            if self.syncToggle {
                self.handleShowSyncDetails()
            } else {
                self.handleHideSyncDetails()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeViews()
        self.displayMultiWalletBalance()
        self.updateRecentActivity()
        self.checkSyncStatus()

        if Settings.readValue(for: Settings.Keys.NewWalletSetUp) {
            Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.walletCreated)
            Settings.setValue(false, for: Settings.Keys.NewWalletSetUp)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func initializeViews() {
        // Set a scroll listener delegate so we can update the nav bar page title text on user scroll.
        self.parentScrollView.delegate = self
        
        self.checkWhetherToPromptForSeedBackup()
        AppDelegate.walletLoader.walletSeedBackedUp.subscribe(with: self) { walletID in
            print("Seed backed up for wallet with ID", walletID)
            self.checkWhetherToPromptForSeedBackup()
        }
        
        self.recentTransactionsTableView.registerCellNib(TransactionTableViewCell.self)
        self.recentTransactionsTableView.delegate = self
        self.recentTransactionsTableView.dataSource = self
    }

    // todo ensure this is always called from the main thread!
    func displayMultiWalletBalance() {
        // todo should use multiwallet balance!
        let totalWalletAmount = AppDelegate.walletLoader.wallet?.totalWalletBalance() ?? 0
        let totalAmountRoundedOff = (Decimal(totalWalletAmount) as NSDecimalNumber).round(8)
        self.balanceLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: UIColor.appColors.darkBlue)
    }
    
    // todo ensure this is always called from the main thread!
    func updateRecentActivity() {
        // Fetch 3 most recent transactions
        // todo this should be a multiwallet fetch rather than a wallet fetch!
        guard let transactions = AppDelegate.walletLoader.wallet?.transactionHistory(offset: 0, count: 3) else {
            self.showNoTransactions()
            return
        }
        
        if transactions.count == 0 {
            self.showNoTransactions()
            return
        }
        
        self.recentTransactions = transactions
        self.recentTransactionsTableView.reloadData()
        
        self.recentTransactionsTableViewHeightContraint.constant = TransactionTableViewCell.height() * CGFloat(self.recentTransactions.count)
    }
    
    func checkSyncStatus() {
        if AppDelegate.walletLoader.multiWallet.isSyncing() {
            self.showSyncDetailsButton.isHidden = false
            self.showSyncDetailsButton.addBorder(atPosition: .top, color: UIColor.appColors.gray, thickness: 0.62)
        } else {
            // Display latest block and connected peer count as long as there's no ongoing sync.
            self.displayLatestBlockHeightAndAge()
            self.displayConnectedPeersCount()
        }
        
        self.attachSyncListeners()
    }
    
    private func displayLatestBlockHeightAndAge() {
        guard let bestBlockInfo = AppDelegate.walletLoader.multiWallet.getBestBlock() else { return }
        
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
        let peerCount = AppDelegate.walletLoader.multiWallet.connectedPeers()
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
    
    // Attach listeners to sync manager and react in this view
    // todo: do we need to use signal?
    func attachSyncListeners() {
        // Subscribe to changes in number of connected peers
        self.syncManager.peers.subscribe(with: self) { _ in
            self.displayConnectedPeersCount()
        }
        
        // Subscribe to changes in sync status
        self.syncManager.syncStatus.subscribe(with: self) { (syncing, status) in
            if syncing {
                self.showSyncStatus()
            } else {
                self.hideSyncStatus()
            }
            
            if status != nil {
                self.syncStatusLabel.text = status
            }
        }
        
        // Monitor network changes and set offline/online indicator on wallet status section
        self.syncManager.networkConnectionStatus = { (status) in
            self.syncStatusImage.image = status ? UIImage(named: "ic_checkmark") : UIImage(named: "ic_crossmark")
            self.onlineStatusIndicator.backgroundColor = status ? UIColor.appColors.green : UIColor.appColors.orange
            self.onlineStatusLabel.text = status ? LocalizedStrings.online : LocalizedStrings.offline
            
            // We need to update sync connect/disconnect button
            self.updateConnectionButton(connected: status, isSyncing: (AppDelegate.walletLoader.multiWallet.isSyncing()))
            
            // We need to reset peer count
            if status == false {
                self.connectedPeersLabel.attributedText = NSMutableAttributedString(string: LocalizedStrings.noConnectedPeer)
            }
        }
    }
 
    // Show sync details on user click "show details" button while syncing
    func handleShowSyncDetails() {
        let detailsView = SyncDetailsComponent(frame: .zero)
        detailsView.horizontalBorder(borderColor: UIColor.black, yPosition: 1, borderHeight: 0.9)
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.clipsToBounds = true
        
        let position = self.syncStatusSection.arrangedSubviews.index(before: self.syncStatusSection.arrangedSubviews.endIndex)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
                self.syncStatusSection.insertArrangedSubview(detailsView, at: position)
                detailsView.heightAnchor.constraint(equalToConstant: 188).isActive = true
                detailsView.widthAnchor.constraint(equalTo: self.syncProgressView.widthAnchor).isActive = true
            })
            self.showSyncDetailsButton.setTitle(LocalizedStrings.hideDetails, for: .normal)
        }
    }
    
    // Hide sync details on "hide details" button click or on sync completion
    func handleHideSyncDetails() {
        //if (AppDelegate.walletLoader.wallet?.isSyncing() == false) { return }
        DispatchQueue.main.async {
             // If the user had clicked on "Show sync details", sync details will be visible after hiding sync progress bar. we need to make sure it is removed first
            if self.syncStatusSection.arrangedSubviews.indices.contains(3) {
                UIView.animate(withDuration: 4.3, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                    self.syncStatusSection.arrangedSubviews[2].removeFromSuperview()
                })
            }
            self.showSyncDetailsButton?.setTitle(LocalizedStrings.showDetails, for: .normal)
        }
    }
    
    // show sync status with progress bar
    func showSyncStatus() {
        // Confirm wallet is actually syncing and sync progressbar is not already shown
        if !AppDelegate.walletLoader.multiWallet.isSyncing() || self.syncProgressBarContainer.isDescendant(of: self.syncProgressView) {
            return
        }
        
        // Remove default latest block label so we can show the progress bar
        self.latestBlockLabel.isHidden = true
        self.connectedPeersLabel.isHidden = true
        
        self.syncStatusImage.image = UIImage(named: "ic_syncing")
        
        // Container for our progress report
        self.syncProgressBarContainer.translatesAutoresizingMaskIntoConstraints = false
        self.syncProgressBarContainer.clipsToBounds = true
        
        // Progress bar
        let progressBar = UIProgressView(frame: CGRect.zero)
        progressBar.layer.cornerRadius = 4 // Because height is 8pts and we want a perfect semi circle curve
        progressBar.progressTintColor = UIColor.appColors.green
        progressBar.trackTintColor = UIColor.appColors.gray
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.clipsToBounds = true
        progressBar.progress = Float(0)
        
        // Overall sync progress percentage
        let percentageLabel = UILabel(frame: CGRect.zero)
        percentageLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        percentageLabel.textColor = UIColor.appColors.darkBlue
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.clipsToBounds = true
        
        // Estimated time left to complete sync
        let timeLeftLabel = UILabel(frame: CGRect.zero)
        timeLeftLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        timeLeftLabel.textColor = UIColor.appColors.darkBlue
        timeLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLeftLabel.clipsToBounds = true
        
        self.syncProgressBarContainer.addSubview(progressBar)
        self.syncProgressBarContainer.addSubview(percentageLabel)
        self.syncProgressBarContainer.addSubview(timeLeftLabel)
        
        // Constraints to position progress view underneath "synchronizing label"
        let constraints: [NSLayoutConstraint] = [
            // Container contraints
            self.syncProgressBarContainer.heightAnchor.constraint(equalToConstant: 30),
            self.syncProgressBarContainer.topAnchor.constraint(equalTo: self.syncStatusLabel.bottomAnchor, constant: 10), // position progress container 10pts below "Synchronizing" label
            self.syncProgressBarContainer.trailingAnchor.constraint(equalTo: self.syncProgressView.trailingAnchor, constant: -16), // Right margin of 16pts
            self.syncProgressBarContainer.leadingAnchor.constraint(equalTo: self.syncProgressView.leadingAnchor, constant: 56), // Left margin of 56pts
            
            // Progress bar constraints
            progressBar.widthAnchor.constraint(equalTo: self.syncProgressBarContainer.widthAnchor), // Full width of parent view
            progressBar.heightAnchor.constraint(equalToConstant: 8), // Height of 8pts from mockup
            progressBar.topAnchor.constraint(equalTo: self.syncProgressBarContainer.topAnchor), // Glue progress bar to top of container view
            
            //Pregress percentage constraints
            percentageLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor),// Position underneath progress bar
            percentageLabel.leadingAnchor.constraint(equalTo: self.syncProgressBarContainer.leadingAnchor), // No right margins
            
            // Estimated time left constraints
            timeLeftLabel.trailingAnchor.constraint(equalTo: self.syncProgressBarContainer.trailingAnchor),
            timeLeftLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
        ]
        
        self.syncProgressView.addSubview(self.syncProgressBarContainer)
        NSLayoutConstraint.activate(constraints)
        
        // Observe sync progress change events and react immediately
        self.syncManager.syncProgress.subscribe(with: self) { (progressReport, headersFetched) in
            guard progressReport != nil else { return }
            timeLeftLabel.text = String(format: LocalizedStrings.syncTimeLeft, progressReport!.totalTimeRemaining)
            percentageLabel.text = String(format: LocalizedStrings.syncProgressComplete, progressReport!.totalSyncProgress)
            progressBar.progress = Float(progressReport!.totalSyncProgress) / 100.0
            self.showSyncDetailsButton.isHidden = false
        }
        
        // We are syncing, update the connection toggle button to show "cancel"
        self.updateConnectionButton(connected: true, isSyncing: true)
    }
    
    // hide sync status progressbar and time on sync complete or cancelled
    func hideSyncStatus() {
        DispatchQueue.main.async {
             // If the user had clicked on "Show sync details", sync details will be visible after hiding sync progress bar. we need to make sure it is removed first
            if self.syncStatusSection.arrangedSubviews.indices.contains(3) {
                UIView.animate(withDuration: 4.3, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                    self.syncStatusSection.arrangedSubviews[2].removeFromSuperview()
                })
            }
            self.showSyncDetailsButton?.setTitle(LocalizedStrings.showDetails, for: .normal)
            
            self.syncProgressBarContainer.removeFromSuperview()
            self.latestBlockLabel.isHidden = false
            self.connectedPeersLabel.isHidden = false
        }
        
        self.displayLatestBlockHeightAndAge()
        self.showSyncDetailsButton.isHidden = true
        
        // We have hidden the progress bar and sync progress report. we need to update the wallet sync status text and indicator
        if AppDelegate.walletLoader.multiWallet.isSyncing() == false {
            let syncStatusImageName = AppDelegate.walletLoader.multiWallet.isSynced() ? "ic_checkmark" : "ic_crossmark"
            self.syncStatusImage.image = UIImage(named: syncStatusImageName)
            self.syncStatusLabel.text = AppDelegate.walletLoader.multiWallet.isSynced() ? LocalizedStrings.walletSynced : LocalizedStrings.walletNotSynced
            self.updatingLatestBlockInfo()
            self.showSyncDetailsButton.isHidden = true
        }
        
        // Next we set the sync connection control button depending on whether or not the wallet synced successfully
        self.updateConnectionButton(connected: AppDelegate.walletLoader.multiWallet.isSynced() ? true : false, isSyncing: false)
        if AppDelegate.walletLoader.isSynced {
            self.updateRecentActivity()
            self.displayMultiWalletBalance()
        }
    }
    
    // Update wallet network connection control button based on sync and network status
    func updateConnectionButton(connected: Bool = false, isSyncing: Bool = false) {
        if self.syncConnectionButton.isHidden {
            self.syncConnectionButton.isHidden = false
        }
        switch connected {
        case true:
            let title = isSyncing ? LocalizedStrings.cancel : LocalizedStrings.disconnect
            self.syncConnectionButton.setTitle(title, for: .normal)
            self.syncConnectionButton.setImage(nil, for: .normal)
            break
        case false:
            self.syncConnectionButton.setImage(UIImage(named: "ic_rescan"), for: .normal)
            self.syncConnectionButton.imageView?.contentMode = .scaleAspectFit
            self.syncConnectionButton.setTitle(LocalizedStrings.reconnect, for: .normal)
        }
    }
    
    // Handle action of sync connect/reconnect/cancel button click based on sync/network status
    @IBAction func syncConnectionButtonTap(_ sender: Any) {
        // TODO: implement action for connection change toggle button
        switch self.syncConnectionButton.titleLabel?.text {
        case LocalizedStrings.cancel, LocalizedStrings.disconnect:
            AppDelegate.walletLoader.multiWallet.cancelSync()
            syncManager.onSyncCanceled(false)
            self.updateConnectionButton(connected: AppDelegate.walletLoader.multiWallet.isSynced(), isSyncing: AppDelegate.walletLoader.multiWallet.isSyncing())
            break
        case LocalizedStrings.reconnect:
            self.stopBestBlockAgeUpdate()
            self.syncManager.isResartingSync = true
            self.syncManager.checkNetworkConnectionForSync()
            break
        default:
            break
        }
    }
    
    // todo rename function
    func updatingLatestBlockInfo() {
        if AppDelegate.walletLoader.multiWallet.isRescanning() {
            return
        }
          
        if self.refreshBestBlockAgeTimer != nil {
            self.refreshBestBlockAgeTimer?.invalidate()
        }
          
        self.refreshBestBlockAgeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            DispatchQueue.main.async {
                self.displayLatestBlockHeightAndAge()
            }
        }
    }
    
    func stopBestBlockAgeUpdate() {
               self.refreshBestBlockAgeTimer?.invalidate()
               self.refreshBestBlockAgeTimer = nil
    }
    
    // Show no transactions label while transaction list is empty
    func showNoTransactions() {
        self.recentTransactionsTableView.isHidden = true
        self.noTransactionsLabelView.superview?.isHidden = false
    }
    
    @IBAction func showOrHideSyncDetails(_ sender: Any) {
        self.syncToggle = !self.syncToggle
    }
    
    // todo not working properly!
    @IBAction func showAllTransactionsTap(_ sender: Any) {
        // Our navigation controller is set as our root view controller, we need to access its already created instance
        let navigation = AppDelegate.shared.window!.rootViewController as! NavigationMenuTabBarController
        // Now we find our transactions controller index on the tab menu
        navigation.viewControllers!.enumerated().forEach({
            if ($0.element.children.first as? TransactionHistoryViewController) != nil {
                navigation.navigateToTab(index: $0.offset) // Tab index found, navigate to it
                return
            }
        })
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

// extension holding methods relating to seed back up section
extension OverviewViewController {
    func checkWhetherToPromptForSeedBackup() {
        // todo should use multiwallet methods to check, not settings
        self.seedBackupSectionView.isHidden = Settings.seedBackedUp
    }
    
    @IBAction func seedBackupTapped(_ sender: Any) {
        let seedBackupReminderVC = SeedBackupReminderViewController.instance().wrapInNavigationcontroller()
        seedBackupReminderVC.modalPresentationStyle = .overFullScreen
        self.present(seedBackupReminderVC, animated: true)
    }
}

// extension methods for recent activity tableview delegate and datasource.
extension OverviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.recentTransactions.count == 0 {
            return
        }
        
        let txDetailsVC = Storyboards.TransactionDetails.instantiateViewController(for: TransactionDetailsViewController.self)
        txDetailsVC.transaction = self.recentTransactions[indexPath.row]
        self.navigationController?.pushViewController(txDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.recentTransactions[indexPath.row].animate {
            cell.blink()
        }
        self.recentTransactions[indexPath.row].animate = false
    }
    
    // todo: what's going on here?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noTransactions = self.recentTransactions.isEmpty
        self.noTransactionsLabelView.superview?.isHidden = !noTransactions
        self.recentTransactionsTableView.isHidden = noTransactions
        self.showAllTransactionsButton.isHidden = noTransactions
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
}

// todo this listener is not attached to any notifier
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
        self.displayMultiWalletBalance()
        
        DispatchQueue.main.async {
            if self.recentTransactions.count > 3 {
                _ = self.recentTransactions.popLast()
            }
            self.recentTransactionsTableView.reloadData()
        }
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
        DispatchQueue.main.async {
            self.displayMultiWalletBalance()
            self.recentTransactionsTableView.reloadData()
        }
    }
}
