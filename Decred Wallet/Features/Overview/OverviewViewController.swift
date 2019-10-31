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
    
    /*
        Main UI components
    */
    
    // Navigation bar
    let navBarTitle = UIView(frame: CGRect.zero) // Custom view because we will be embedding a image and label
    var pageTitleLabel: UILabel!
    
    @IBOutlet weak var parentScrollView: UIScrollView! // Scroll view holding the entire contents of this view.
    @IBOutlet weak var balanceLabel: UILabel! {
        didSet { self.balanceLabel.font = UIFont(name: "Source Sans Pro", size: 40) }
    }
    
    // MARK: Backup phrase section (Top view)
    @IBOutlet weak var seedBackupSectionView: UIView!
    
    // MARK: Transaction history section
    @IBOutlet weak var recentActivitySection: UIStackView!
    @IBOutlet weak var recentActivityLabelView: UIView!
    @IBOutlet weak var noTransactionsLabelView: UIView! // to show "No recent transactions"
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var showAllTransactionsButton: UIButton!
    
    // MARK: Sync status section
    @IBOutlet weak var syncStatusSection: UIStackView!
    @IBOutlet weak var walletStatusLabelView: UIView!
    @IBOutlet weak var onlineStatusIndicator: UIView!
    @IBOutlet weak var onlineStatusLabel: UILabel! {
        didSet {
            self.onlineStatusLabel.font = UIFont(name: "Source Sans Pro", size: 12)
        }
    }
    @IBOutlet weak var syncProgressView: UIView!
    @IBOutlet weak var syncStatusImage: UIImageView!
    @IBOutlet weak var syncStatusLabel: UILabel! {
        didSet {
            self.syncStatusLabel.text = (AppDelegate.walletLoader.isSynced == true) ? LocalizedStrings.walletSynced : LocalizedStrings.walletNotSynced
            self.syncStatusLabel.font = UIFont(name: "Source Sans Pro", size: 20)
        }
    }
    @IBOutlet weak var latestBlockLabel: UILabel!
    @IBOutlet weak var connectedPeersLabel: UILabel! {
        didSet { self.connectedPeersLabel.font = UIFont.init(name: "Source Sans Pro", size: 16) }
    }
    @IBOutlet weak var showSyncDetailsButton: UIButton! {
        didSet { self.showSyncDetailsButton.isHidden = (AppDelegate.walletLoader.wallet?.isSyncing() == true) ? true : false; self.showSyncDetailsButton.clipsToBounds = true; }
    }
    
    @IBOutlet weak var syncConnectionButton: UIButton!
    
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
        
        self.setupInterface()
        self.attachSyncListeners()
        
        // Setup delegates
        self.parentScrollView.tag = 2
        self.parentScrollView.delegate = self // This is so we can update the navigation bar on user scroll. Our transactions tableview will hold a scrollview when populated and we want to differentiate that, hence this tag
        
        if AppDelegate.walletLoader.isSynced {
            self.updateRecentActivity()
        }else{
            self.showNoTransactions()
        }
        self.updateCurrentBalance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layer.backgroundColor = UIColor(hex: "#f3f5f6").cgColor
        
        // Setup stackviews properly with rounded corners
        DispatchQueue.main.async {
            self.recentActivitySection.layer.backgroundColor = UIColor.white.cgColor
            self.recentActivitySection.cornerRadius(18)
            self.syncStatusSection.layer.backgroundColor = UIColor.white.cgColor
            self.syncStatusSection.cornerRadius(18)
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
        }
    }
    
    private func setupInterface() {
        // Navigation bar and page title
        let logoImage = UIImageView(frame: CGRect(x: 24, y: 10, width: 24, height: 24))
        logoImage.contentMode = .scaleAspectFit
        logoImage.image = UIImage(named: "ic_decred")
        logoImage.clipsToBounds = true
        
        self.pageTitleLabel = UILabel(frame: CGRect(x: 64, y: 10, width: 400, height: 20)) // position the overview label 64pts from the screens left edge and 10pts from the top of the navigation bar
        self.pageTitleLabel.font = UIFont(name: "Source Sans Pro", size: 20)
        self.pageTitleLabel.text = LocalizedStrings.overview
        self.pageTitleLabel.clipsToBounds = true
        
        self.navBarTitle.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 56)
        self.navBarTitle.addSubview(logoImage)
        self.navBarTitle.addSubview(self.pageTitleLabel)
        self.navigationItem.titleView = self.navBarTitle // set our navigation item to our custom navbar view
        
        // Setup seed backup warning
        self.seedBackupSectionView.layer.cornerRadius = 14
        self.seedBackupSectionView.layer.shadowPath = UIBezierPath(roundedRect: self.seedBackupSectionView.bounds, cornerRadius: self.seedBackupSectionView.layer.cornerRadius).cgPath
        self.seedBackupSectionView.layer.shadowColor = UIColor(displayP3Red: 0.04, green: 0.08, blue: 0.25, alpha: 0.04).cgColor
        self.seedBackupSectionView.layer.shadowOffset = CGSize(width: 8, height: 8)
        self.seedBackupSectionView.layer.shadowOpacity = 0.4
        self.seedBackupSectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBackupWallet))) // show wallet backup on tap
        
        // Sync status section
        self.onlineStatusIndicator.layer.cornerRadius = 5 // Height/width is 10pts, we use half that (5pts) to make a perfect circle
        self.syncStatusImage.image = AppDelegate.walletLoader.isSynced ? UIImage(named: "ic_checkmark") : UIImage(named: "ic_crossmark") // Initial sync status image
        
        let latestBlock = AppDelegate.walletLoader.wallet?.getBestBlock() ?? 0
        let latestBlockAge = self.setBestBlockAge()
        self.latestBlockLabel.text = String(format: LocalizedStrings.latestBlockAge, latestBlock, latestBlockAge)
        self.connectedPeersLabel.text = String(format: LocalizedStrings.connectedTo, 0)
        
        self.showSyncDetailsButton.addBorder(atPosition: .top, color: UIColor.appColors.lightGray, thickness: 0.62)
        self.showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
        self.showSyncDetailsButton.isHidden = true // Hide show details button till we determine sync status
        self.showSyncDetailsButton.addTarget(self, action: #selector(self.handleShowSyncToggle), for: .touchUpInside)
        
        // Sync network connect/disconnect/cancel button setup
        self.syncConnectionButton.layer.borderWidth = 1
        self.syncConnectionButton.layer.borderColor = UIColor.appColors.lightGray.cgColor
        self.syncConnectionButton.layer.cornerRadius = 12 // Height is 24pts from mockup so we use use 12pts for rounded left & right edges
//        self.syncConnectionButton.isHidden = true // initially hidden because we only want to show it while sync is active
        self.syncConnectionButton.addTarget(self, action: #selector(self.connectionToggle), for: .touchUpInside)
        
        // Transactions section setup
        self.recentActivityLabelView.horizontalBorder(borderColor: UIColor.appColors.lightGray, yPosition: self.recentActivityLabelView.frame.maxY-7, borderHeight: 0.64)
        self.recentTransactionsTableView.registerCellNib(TransactionTableViewCell.self)
        self.recentTransactionsTableView.delegate = self
        self.recentTransactionsTableView.dataSource = self
        
        // Add pull to refresh capability to recent transactions table
        let pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.addTarget(self, action: #selector(self.handleRecentActivityTableRefresh(_:)), for: UIControl.Event.valueChanged)
        pullToRefreshControl.tintColor = UIColor.lightGray
        self.recentTransactionsTableView.addSubview(pullToRefreshControl) // refresh control added
        
        self.showAllTransactionsButton.setTitle(LocalizedStrings.showAllTransactions, for: .normal)
        self.showAllTransactionsButton.isHidden = (self.recentTransactions.count > 3) ? false : true
    }
    
    // Attach listeners to sync manager and react in this view
    func attachSyncListeners() {
        // Subscribe to changes in number of connected peers
        self.syncManager.peers.subscribe(with: self) { (peers) in
            self.connectedPeersLabel.text = String(format: LocalizedStrings.connectedTo, peers)
        }
        
        // Subscribe to changes in sync status
        self.syncManager.syncing.subscribe(with: self) { (syncing, status) in
            _ = syncing ? self.showSyncStatus() : self.hideSyncStatus()
            if status != nil {
                self.syncStatusLabel.text = status
            }
        }
        
        // Monitor network changes and set offline/online indicator on wallet status section
        self.syncManager.connectedToNetwork = { (status) in
            self.onlineStatusIndicator.layer.backgroundColor = status ? UIColor.appColors.decredGreen.cgColor : UIColor.appColors.decredOrange.cgColor
            self.onlineStatusLabel.text = status ? LocalizedStrings.online : LocalizedStrings.offline
            
            // We need to update sync connect/disconnect button
            self.updateConnectionButton(connected: status)
        }
    }
    
    @objc func handleRecentActivityTableRefresh(_ refreshControl: UIRefreshControl) {
        self.updateRecentActivity()
        refreshControl.endRefreshing()
    }
    
    @objc func handleBackupWallet() {
        // TODO: When implementing backup page
    }
    
    // Update wallet network connection control button based on sync and network status
    func updateConnectionButton(connected: Bool = false, isSyncing: Bool = false) {
        if self.syncConnectionButton.isHidden {
            self.syncConnectionButton.isHidden = false
        }
        switch connected {
        case true:
            let title = isSyncing ? LocalizedStrings.cancel : LocalizedStrings.disconnnect
            self.syncConnectionButton.setTitle(title, for: .normal)
            self.syncConnectionButton.setImage(nil, for: .normal)
            break
        case false:
            self.syncConnectionButton.setImage(UIImage(named: "ic_rescan"), for: .normal)
            self.syncConnectionButton.imageView?.contentMode = .scaleAspectFit
            self.syncConnectionButton.setTitle(LocalizedStrings.reconnect, for: .normal)
            break
        }
    }
    
    // Handle action of sync connect/reconnect/cancel button click based on sync/network status
    @objc func connectionToggle() {
        // TODO: implement action for connection change toggle button
    }
    
    func updateRecentActivity() {
        // Fetch 5 most recent transactions
        guard let transactions = AppDelegate.walletLoader.wallet?.transactionHistory(offset: Int32(0), count: Int32(5)) else {
            self.showNoTransactions()
            return
        }
        
        if transactions.count == 0 {
            self.showNoTransactions()
            return
        }
        
        DispatchQueue.main.async {
            self.recentTransactions = transactions
            self.recentTransactionsTableView.backgroundView = nil
            self.recentTransactionsTableView.separatorStyle = .singleLine
            self.recentTransactionsTableView.reloadData()
        }
    }
    
    func updateCurrentBalance() {
        DispatchQueue.main.async {
            let totalWalletAmount = AppDelegate.walletLoader.wallet?.totalWalletBalance()
            let totalAmountRoundedOff = (Decimal(totalWalletAmount!) as NSDecimalNumber).round(8)
            self.balanceLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: GlobalConstants.Colors.TextAmount)
        }
    }
    
    // Show no transactions label while transaction list is empty
    func showNoTransactions() {
        self.recentTransactionsTableView.isHidden = true
        self.noTransactionsLabelView.isHidden = false
    }
    
    // show sync status with progress bar
    func showSyncStatus() {
        
        if !(AppDelegate.walletLoader.wallet?.isSyncing())! {
            return
        }
        let blockAge = self.setBestBlockAge()
        let bestBlock = AppDelegate.walletLoader.wallet!.getBestBlock()
        self.latestBlockLabel.text = String(format: LocalizedStrings.latestBlockAge, bestBlock, blockAge)
        
        // Remove default latest block label so we an show the progress bar
        self.latestBlockLabel.isHidden = true
        self.connectedPeersLabel.isHidden = true
        
        if self.showSyncDetailsButton.isHidden == true {
            self.showSyncDetailsButton.isHidden = false
        }
        
        self.syncStatusImage.image = UIImage(named: "ic_syncing")
        
        // Container for our progress report
        self.syncProgressBarContainer.translatesAutoresizingMaskIntoConstraints = false
        self.syncProgressBarContainer.clipsToBounds = true
        
        // Progress bar
        let progressBar = UIProgressView(frame: CGRect.zero)
        progressBar.layer.cornerRadius = 4 // Height will be 8pts, so a 4pts corner radius for semi-circle curve
        progressBar.progressTintColor = UIColor.appColors.decredGreen
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.clipsToBounds = true
        
        // Overall sync progress percentage
        let percentageLabel = UILabel(frame: CGRect.zero)
        percentageLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.clipsToBounds = true
        
        // Estimated time left to complete sync
        let timeLeftLabel = UILabel(frame: CGRect.zero)
        timeLeftLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        timeLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLeftLabel.clipsToBounds = true
        
        self.syncProgressBarContainer.addSubview(progressBar)
        self.syncProgressBarContainer.addSubview(percentageLabel)
        self.syncProgressBarContainer.addSubview(timeLeftLabel)
        
        // Constraints to position progress view underneath "synchronizing label"
        let constraints: [NSLayoutConstraint] = [
            // Container contraints
            self.syncProgressBarContainer.heightAnchor.constraint(equalToConstant: 32),
            self.syncProgressBarContainer.topAnchor.constraint(equalTo: self.syncStatusLabel.bottomAnchor, constant: 10), // position progress container 10pts below "Synchronizing" label
            self.syncProgressBarContainer.trailingAnchor.constraint(equalTo: self.syncProgressView.trailingAnchor, constant: 0.031), // Right margin of 31pts
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
        }
        
        // We are syncing, update the connection toggle button to show "cancel"
        self.updateConnectionButton(connected: true, isSyncing: true)
        self.updateRecentActivity()
    }
    
    // Action for when show/hide sync details button is tapped
    @objc func handleShowSyncToggle() {
        if self.syncToggle {
            self.syncToggle = false
        }else{
            self.syncToggle = true
        }
    }
    
    // Show sync details on user click "show details" button while syncing
    func handleShowSyncDetails() {
        let component = self.syncDetailsComponent()
        let position = self.syncStatusSection.arrangedSubviews.index(before: self.syncStatusSection.arrangedSubviews.endIndex)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.syncStatusSection.insertArrangedSubview(component.view, at: position)
                component.view.heightAnchor.constraint(equalToConstant: 188).isActive = true
                component.view.topAnchor.constraint(equalTo: self.syncProgressView.bottomAnchor).isActive = true
                self.syncStatusSection.bottomAnchor.constraint(equalTo: self.syncStatusSection.safeAreaLayoutGuide.bottomAnchor, constant: -2).isActive = true
                NSLayoutConstraint.activate(component.constraints)
            }
        }
        self.showSyncDetailsButton.setTitle(LocalizedStrings.hideDetails, for: .normal)
    }
    
    // Hide sync details on "hide details" button click or on sync completion
    func handleHideSyncDetails() {
        if (AppDelegate.walletLoader.wallet?.isSyncing() == true) { return }
        
        if self.syncStatusSection.arrangedSubviews.indices.contains(2) {
            UIView.animate(withDuration: 4.3){
                self.syncStatusSection.arrangedSubviews[2].removeFromSuperview()
            }
        }
        self.showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
    }
    
    // hide sync status progressbar and time on sync complete or cancelled
    func hideSyncStatus() {
        // Sometimes sync details may be visible after hiding sync progress bar. we need to remove it first it just in case
        self.handleHideSyncDetails()
        
        DispatchQueue.main.async {
            self.syncProgressBarContainer.removeFromSuperview()
            self.latestBlockLabel.isHidden = false
            self.connectedPeersLabel.isHidden = false
        }
        
        let blockAge = self.setBestBlockAge()
        let bestBlock = AppDelegate.walletLoader.wallet!.getBestBlock()
        self.latestBlockLabel.text = String(format: LocalizedStrings.latestBlockAge, bestBlock, blockAge)
        self.showSyncDetailsButton.isHidden = true
        
        if (AppDelegate.walletLoader.wallet?.isSyncing() == false) {
            let syncStatusImageName = (AppDelegate.walletLoader.wallet?.isSynced())! ? "ic_checkmark" : "ic_crossmark"
            self.syncStatusImage.image = UIImage(named: syncStatusImageName)
            self.syncStatusLabel.text = (AppDelegate.walletLoader.wallet?.isSynced())! ? LocalizedStrings.walletSynced : LocalizedStrings.walletNotSynced
            self.showSyncDetailsButton.isHidden = true
            
        }
        
        self.updateConnectionButton(connected: (AppDelegate.walletLoader.wallet?.isSynced())! ? true : false, isSyncing: false)
        self.updateRecentActivity()
        self.updateCurrentBalance()
    }
    
    // Sync details view. this component is generated on the fly only when the wallet is syncing
    func syncDetailsComponent() -> (view: UIView, constraints: [NSLayoutConstraint]) {
        // containing view for details
        let detailsContainerView = UIView(frame: CGRect.zero)
        detailsContainerView.layer.backgroundColor = UIColor.white.cgColor
        detailsContainerView.translatesAutoresizingMaskIntoConstraints = false
        // Inner component holding full details
        let detailsView = UIView(frame: CGRect.zero), stepsLabel = UILabel(frame: CGRect.zero), stepDetailLabel = UILabel(frame: CGRect.zero), headersFetchedLabel = UILabel(frame: CGRect.zero), headersFetchedCount = UILabel(frame: CGRect.zero), syncProgressLabel = UILabel(frame: CGRect.zero), syncProgressCount = UILabel(frame: CGRect.zero), numberOfPeersLabel = UILabel(frame: CGRect.zero), numberOfPeersCount = UILabel(frame: CGRect.zero)
        detailsView.layer.backgroundColor = UIColor.init(hex: "#f3f5f6").cgColor
        detailsView.layer.cornerRadius = 8
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.clipsToBounds = true
        // Current step indicator
        stepsLabel.font = UIFont(name: "Source Sans Pro", size: 13)
        stepsLabel.text = String(format: LocalizedStrings.syncSteps, 0)
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.clipsToBounds = true
        // Current step action/progress
        stepDetailLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        stepDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        stepDetailLabel.clipsToBounds = true
        // fetched headers text
        headersFetchedLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        headersFetchedLabel.text = LocalizedStrings.blockHeadersFetched
        headersFetchedLabel.translatesAutoresizingMaskIntoConstraints = false
        headersFetchedLabel.clipsToBounds = true
        // Fetched headers count
        headersFetchedCount.font = UIFont(name: "Source Sans Pro", size: 14)
        headersFetchedCount.translatesAutoresizingMaskIntoConstraints = false
        headersFetchedCount.clipsToBounds = true
        // Syncing progress text
        syncProgressLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        syncProgressLabel.text = LocalizedStrings.syncingProgress
        syncProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        syncProgressLabel.clipsToBounds = true
        // block age behind
        syncProgressCount.font = UIFont(name: "Source Sans Pro", size: 14)
        syncProgressCount.translatesAutoresizingMaskIntoConstraints = false
        syncProgressCount.clipsToBounds = true
        // Connected peers
        numberOfPeersLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        numberOfPeersLabel.text = LocalizedStrings.connectedPeersCount
        numberOfPeersLabel.translatesAutoresizingMaskIntoConstraints = false
        numberOfPeersLabel.clipsToBounds = true
        // show connected peers count
        numberOfPeersCount.font = UIFont(name: "Source Sans Pro", size: 14)
        numberOfPeersCount.text = "0"
        numberOfPeersCount.translatesAutoresizingMaskIntoConstraints = false
        numberOfPeersCount.clipsToBounds = true
        
        // Add them  to the detailsview
        detailsView.addSubview(headersFetchedLabel)
        detailsView.addSubview(headersFetchedCount) // %headersFetched% of %total header%
        detailsView.addSubview(syncProgressLabel) // Syncing progress
        detailsView.addSubview(syncProgressCount) // days behind count
        detailsView.addSubview(numberOfPeersLabel) // Connected peers count label
        detailsView.addSubview(numberOfPeersCount) // number of connected peers
        
        // Positioning constraints for full sync details. numbers are from mockup
        let detailsViewConstraints = [
            // View holding details data/text
            detailsView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 46), // 46pts space from top of container from mockup
            detailsView.heightAnchor.constraint(equalToConstant: 112), // 112pts height from mockup
            detailsView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -20),
            detailsView.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 16),
            detailsView.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -16),
            // Headers fetch progress
            headersFetchedLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            headersFetchedLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 17),
            headersFetchedLabel.heightAnchor.constraint(equalToConstant: 16),
            headersFetchedCount.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            headersFetchedCount.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 17),
            headersFetchedCount.heightAnchor.constraint(equalToConstant: 14),
            // Wallet sync progress (i.e ledger current age or days behind)
            syncProgressLabel.heightAnchor.constraint(equalToConstant: 16),
            syncProgressLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            syncProgressLabel.topAnchor.constraint(equalTo: headersFetchedLabel.bottomAnchor, constant: 18),
            syncProgressCount.topAnchor.constraint(equalTo: headersFetchedCount.bottomAnchor, constant: 16),
            syncProgressCount.heightAnchor.constraint(equalToConstant: 16),
            syncProgressCount.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            // Number of peers currently connected
            numberOfPeersLabel.heightAnchor.constraint(equalToConstant: 16),
            numberOfPeersLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            numberOfPeersLabel.topAnchor.constraint(equalTo: syncProgressLabel.bottomAnchor, constant: 18),
            numberOfPeersCount.topAnchor.constraint(equalTo: syncProgressCount.bottomAnchor, constant: 16),
            numberOfPeersCount.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            numberOfPeersCount.heightAnchor.constraint(equalToConstant: 15),
            // Current sync step (1,2 or 3)
            stepsLabel.heightAnchor.constraint(equalToConstant: 14),
            stepsLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 16),
            stepsLabel.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 16),
            stepDetailLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 16),
            stepDetailLabel.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -16),
            stepDetailLabel.heightAnchor.constraint(equalToConstant: 16),
        ]
        
        // Add all components to superview (details container)
        detailsContainerView.addSubview(stepsLabel)
        detailsContainerView.addSubview(stepDetailLabel)
        detailsContainerView.addSubview(detailsView)
        detailsContainerView.clipsToBounds = true
        
        // Subscribe to general sync progress changes for use in this component
        self.syncManager.syncProgress.subscribe(with: self) { (progressReport, headersFetched) in
            if headersFetched != nil{
                DispatchQueue.main.async {
                    headersFetchedCount.text = String(format: LocalizedStrings.fetchedHeaders, headersFetched!.fetchedHeadersCount, headersFetched!.totalHeadersToFetch)
                    
                    if headersFetched!.bestBlockAge != "" {
                        syncProgressCount.text = String(format: LocalizedStrings.bestBlockAgebehind, headersFetched!.bestBlockAge)
                        syncProgressCount.sizeToFit()
                    }
                }
            }
        }
        // Subscribe to connected peers changes and react in this component only
        self.syncManager.peers.subscribe(with: self) { (peers) in
            DispatchQueue.main.async {
                numberOfPeersCount.text = String(peers)
            }
        }
        // Subscribe to changes in synchronization stage and react in this component only
        self.syncManager.syncStage.subscribe(with: self){ (stage, reportText) in
            DispatchQueue.main.async {
                stepsLabel.text = String(format: LocalizedStrings.syncSteps, stage)
                stepDetailLabel.text = reportText
            }
        }
        return (detailsContainerView, detailsViewConstraints)
    }
    
    func setBestBlockAge() -> String {
        if AppDelegate.walletLoader.wallet!.isScanning() {
            return ""
        }
        
        let bestBlockAge = Int64(Date().timeIntervalSince1970) - AppDelegate.walletLoader.wallet!.getBestBlockTimeStamp()
        
        switch bestBlockAge {
        case Int64.min...0:
            return LocalizedStrings.now
            
        case 0..<Utils.TimeInSeconds.Minute:
            return String(format: LocalizedStrings.secondsAgo, bestBlockAge)
            
        case Utils.TimeInSeconds.Minute..<Utils.TimeInSeconds.Hour:
            let minutes = bestBlockAge / Utils.TimeInSeconds.Minute
            return String(format: LocalizedStrings.minAgo, minutes)
            
        case Utils.TimeInSeconds.Hour..<Utils.TimeInSeconds.Day:
            let hours = bestBlockAge / Utils.TimeInSeconds.Hour
            return String(format: LocalizedStrings.hrsAgo, hours)
            
        case Utils.TimeInSeconds.Day..<Utils.TimeInSeconds.Week:
            let days = bestBlockAge / Utils.TimeInSeconds.Day
            return String(format: LocalizedStrings.daysAgo, days)
            
        case Utils.TimeInSeconds.Week..<Utils.TimeInSeconds.Month:
            let weeks = bestBlockAge / Utils.TimeInSeconds.Week
            return String(format: LocalizedStrings.weeksAgo, weeks)
            
        case Utils.TimeInSeconds.Month..<Utils.TimeInSeconds.Year:
            let months = bestBlockAge / Utils.TimeInSeconds.Month
            return String(format: LocalizedStrings.monthsAgo, months)
            
        default:
            let years = bestBlockAge / Utils.TimeInSeconds.Year
            return String(format: LocalizedStrings.yearsAgo, years)
        }
    }
}

extension OverviewViewController: NewTransactionNotificationProtocol, ConfirmedTransactionNotificationProtocol {
    func onTransaction(_ transaction: String?) {
        var tx = try! JSONDecoder().decode(Transaction.self, from:(transaction!.utf8Bits))
        
        if self.recentTransactions.contains(where: { $0.hash == tx.hash }) {
            // duplicate notification, tx is already being displayed in table
            return
        }
        
        tx.animate = true
        self.recentTransactions.insert(tx, at: 0)
        self.updateCurrentBalance()
        
        DispatchQueue.main.async {
            let maxDisplayItems = round(self.recentTransactionsTableView.frame.size.height / TransactionTableViewCell.height())
            if self.recentTransactions.count > Int(maxDisplayItems) {
                _ = self.recentTransactions.popLast()
            }
            self.recentTransactionsTableView.reloadData()
        }
    }
    
    func onTransactionConfirmed(_ hash: String?, height: Int32) {
        DispatchQueue.main.async {
            self.updateCurrentBalance()
        }
    }
}

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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.showAllTransactionsButton.isHidden = (self.recentTransactions.count > 2) ? false : true
        self.noTransactionsLabelView.isHidden = (self.recentTransactions.count > 0) ? true : false
        self.recentTransactionsTableView.isHidden = (self.recentTransactions.count > 0) ? false : true
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

extension OverviewViewController: UIScrollViewDelegate {
    // Update overview label on navigation bar to show wallet balance on scroll down
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        // We are targetting only the parent scroll view which we gave a tag of 2. this is because this view holds a tableview that can be scrolled and we do not want to react to that
        if scrollView.tag == 2 {
            if (actualPosition.y > 1) {
                self.pageTitleLabel.text = LocalizedStrings.overview
            } else {
                self.pageTitleLabel.attributedText = self.balanceLabel.attributedText!
            }
        }
    }
}
