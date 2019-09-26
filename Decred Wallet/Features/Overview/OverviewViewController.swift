//
//  OverviewViewControllerr.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet
import Signals

class OverviewViewController: UIViewController{
    // Heading & balance
    @IBOutlet weak var logoImage: UIImageView!
//    @IBOutlet weak var overViewLabel: UILabel! {
//        didSet { self.overViewLabel.text = LocalizedStrings.overview }
//    }
    @IBOutlet weak var balanceLabel: UILabel! {
        didSet { self.balanceLabel.font = UIFont(name: "Source Sans Pro", size: 40) }
    }
    @IBOutlet weak var currentBalanceLabel: UILabel! {
        didSet {
            self.currentBalanceLabel.text = LocalizedStrings.currentTotalBalance
            self.currentBalanceLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        }
    }
    
    // Backup phrase section (Top view)
    @IBOutlet weak var seedBackupSectionView: UIView!
    
    @IBOutlet weak var backupSeedPhrase: UILabel! {
        didSet{
            self.backupSeedPhrase.font = UIFont(name: "Source Sans Pro", size: 16)
            self.backupSeedPhrase.text = LocalizedStrings.backupSeedPhrase
        }
    }
    
    @IBOutlet weak var backupWarningText: UILabel! {
        didSet { self.backupWarningText.font = UIFont(name: "Source Sans Pro", size: 14) }
    }
    
    // MARK: Transaction history section
    @IBOutlet weak var recentActivitySection: UIStackView!
    @IBOutlet weak var recentActivityLabelView: UIView!
    @IBOutlet weak var recentActivityLabel: UILabel! {
        didSet {
            self.recentActivityLabel.text = LocalizedStrings.recentTransactions
            self.recentActivityLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        }
    }
    @IBOutlet weak var recentTransactionsTableView: UITableView!
    @IBOutlet weak var showAllTransactionsButton: UIButton!
    
    // MARK: Sync status section
    @IBOutlet weak var syncStatusSection: UIStackView! {
        didSet { self.syncStatusSection.cornerRadius(18) }
    }
    @IBOutlet weak var walletStatusLabelView: UIView!
    @IBOutlet weak var walletStatusLabel: UILabel! {
        didSet {
            self.walletStatusLabel.text = LocalizedStrings.walletStatus
            self.walletStatusLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        }
    }
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
            self.syncStatusLabel.text = (AppDelegate.walletLoader.isSynced) ? LocalizedStrings.walletSynced : LocalizedStrings.walletNotSynced
            self.syncStatusLabel.font = UIFont(name: "Source Sans Pro", size: 20)
        }
    }
    @IBOutlet weak var latestBlockLabel: UILabel!
    @IBOutlet weak var connectedPeersLabel: UILabel! {
        didSet { self.connectedPeersLabel.font = UIFont.init(name: "Source Sans Pro", size: 16)}
    }
    @IBOutlet weak var showSyncDetailsButton: UIButton! {
        didSet { self.showSyncDetailsButton.isHidden = (AppDelegate.walletLoader.wallet?.isSyncing() == true) ? true : false; self.showSyncDetailsButton.clipsToBounds = true; }
    }
    
    var recentTransactions = [Transaction]()
    let syncProgress =  Signal<(DcrlibwalletGeneralSyncProgress?, DcrlibwalletHeadersFetchProgressReport?)>()
    let peers = Signal<Int32>()
    let syncStage = Signal<(Int, String)>()
    
    var syncToggle: Bool = false {
        didSet{
            if syncToggle {
                handleShowSyncDetails()
            }else{
                handleHideSyncDetails()
            }
        }
    }
    var syncing: Bool = false {
        didSet {
            if self.syncing {
                showSyncStatus()
                self.onlineStatusIndicator.backgroundColor = UIColor.appColors.decredGreen
                self.onlineStatusLabel.text = LocalizedStrings.online
            }else{
                hideSyncStatus()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor(hex: "#f3f5f6").cgColor
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
        AppDelegate.walletLoader.syncer.registerEstimatedSyncProgressListener()
        self.setupInterface()
        
        self.seedBackupSectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleBackupWallet)))
        self.showSyncDetailsButton.addTarget(self, action: #selector(self.handleShowSyncToggle), for: .touchUpInside)
        
        let pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.addTarget(self, action: #selector(self.handleRecentActivityTableRefresh(_:)), for: UIControl.Event.valueChanged)
        pullToRefreshControl.tintColor = UIColor.lightGray
        
        self.recentActivityLabelView.horizontalBorder(borderColor: UIColor(red: 0.24, green: 0.35, blue: 0.45, alpha: 0.5), yPosition: self.recentActivityLabelView.frame.maxY-1, borderHeight: 0.62)
        
        self.recentTransactionsTableView.registerCellNib(TransactionTableViewCell.self)
        self.recentTransactionsTableView.delegate = self
        self.recentTransactionsTableView.dataSource = self
        self.recentTransactionsTableView.addSubview(pullToRefreshControl)
        
        
        
        if AppDelegate.walletLoader.isSynced {
            self.updateRecentActivity()
        }else{
            self.showNoTransactions()
        }
        self.updateCurrentBalance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.96, alpha: 1)
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.recentActivitySection.layer.backgroundColor = UIColor.white.cgColor
            self.recentActivitySection.cornerRadius(18)
            self.syncStatusSection.layer.backgroundColor = UIColor.white.cgColor
            self.syncStatusSection.cornerRadius(18)
        }
    }
    
    private func setupInterface() {
        self.seedBackupSectionView.layer.cornerRadius = 14
        self.seedBackupSectionView.layer.shadowPath = UIBezierPath(roundedRect: self.seedBackupSectionView.bounds, cornerRadius: self.seedBackupSectionView.layer.cornerRadius).cgPath
        self.seedBackupSectionView.layer.shadowColor = UIColor(displayP3Red: 0.04, green: 0.08, blue: 0.25, alpha: 0.04).cgColor
        self.seedBackupSectionView.layer.shadowOffset = CGSize(width: 8, height: 8)
        self.seedBackupSectionView.layer.shadowOpacity = 0.4
        
        self.backupWarningText.text = LocalizedStrings.backupWarningText
        // Sync status section
        self.onlineStatusIndicator.layer.cornerRadius = 7
        self.onlineStatusIndicator.layer.backgroundColor = (AppDelegate.shared.reachability.connection != .none) ? UIColor.appColors.decredGreen.cgColor : UIColor.red.cgColor
        self.onlineStatusLabel.text = (AppDelegate.shared.reachability.connection != .none) ? LocalizedStrings.online : LocalizedStrings.offline
        self.syncStatusImage.image = (AppDelegate.walletLoader.isSynced) ? UIImage(named: "ic_checkmark01_24px") : UIImage(named: "ic_crossmark_24px")
        
        self.onlineStatusIndicator.layer.cornerRadius = 7
        self.onlineStatusIndicator.layer.backgroundColor = (AppDelegate.shared.reachability.connection != .none) ? UIColor.appColors.decredGreen.cgColor : UIColor.red.cgColor
        self.onlineStatusLabel.text = (AppDelegate.shared.reachability.connection != .none) ? LocalizedStrings.online : LocalizedStrings.offline
        
        self.syncStatusImage.image = (AppDelegate.walletLoader.isSynced) ? UIImage(named: "ic_checkmark01_24px") : UIImage(named: "ic_crossmark_24px")
        
        let latestBlock = AppDelegate.walletLoader.wallet?.getBestBlock() ?? 0
        let latestBlockAge = self.setBestBlockAge()
        self.latestBlockLabel.text = String(format: LocalizedStrings.latestBlockAge, latestBlock, latestBlockAge)
        self.connectedPeersLabel.text = String(format: LocalizedStrings.connectedTo, 0)
        
        self.showSyncDetailsButton.addBorder(atPosition: .top, color: UIColor.appColors.lightGray, thickness: 0.54)
        self.showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
        self.showSyncDetailsButton.isHidden = (self.syncing == true) ? false : true
        
        // Transactions section
        self.showAllTransactionsButton.setTitle(LocalizedStrings.showAllTransactions, for: .normal)
        self.showAllTransactionsButton.isHidden = (self.recentTransactions.count > 3) ? false : true
        
        self.navigationController?.isNavigationBarHidden = true
        // Signals here
        self.peers.subscribe(with: self){ (peers) in
            self.connectedPeersLabel.text = String(format: LocalizedStrings.connectedTo, peers)
        }
    }
    
    @objc func handleRecentActivityTableRefresh(_ refreshControl: UIRefreshControl) {
        self.updateRecentActivity()
        refreshControl.endRefreshing()
    }
    
    @objc func handleBackupWallet() {
        // TODO: When implementing backup page
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
    
    func showNoTransactions() {
        let noTransactionsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.recentTransactionsTableView.bounds.size.width, height: self.recentTransactionsTableView.bounds.size.height))
        noTransactionsLabel.text = LocalizedStrings.noTransactions
        noTransactionsLabel.textAlignment = .center
        noTransactionsLabel.textColor = UIColor(displayP3Red: 0.54, green: 0.59, blue: 0.65, alpha: 1)
        noTransactionsLabel.font = UIFont(name: "Source Sans Pro", size: 16)
        DispatchQueue.main.async {
            self.recentTransactionsTableView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            self.recentTransactionsTableView.backgroundView = noTransactionsLabel
            self.recentTransactionsTableView.separatorStyle = .none
        }
        
    }
    
    func showSyncStatus() {
        
        if AppDelegate.walletLoader.wallet?.isSyncing() == false{
            return
        }
        let blockAge = self.setBestBlockAge()
        let bestBlock = AppDelegate.walletLoader.wallet!.getBestBlock()
        self.latestBlockLabel.text = String(format: LocalizedStrings.latestBlockAge, bestBlock, blockAge)
        self.showSyncDetailsButton.isHidden = true
        self.updateRecentActivity()
    }
    
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
        if self.syncStatusSection.arrangedSubviews.indices.contains(2) {
            UIView.animate(withDuration: 4.3){
                self.syncStatusSection.arrangedSubviews[2].removeFromSuperview()
            }
        }
        showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
    }
    
    // Sync details view
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
        stepDetailLabel.text = ""
        stepDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        stepDetailLabel.clipsToBounds = true
        // fetched headers text
        headersFetchedLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        headersFetchedLabel.text = LocalizedStrings.blockHeadersFetched
        headersFetchedLabel.translatesAutoresizingMaskIntoConstraints = false
        headersFetchedLabel.clipsToBounds = true
        // Fetched headers count
        headersFetchedCount.font = UIFont(name: "Source Sans Pro", size: 14)
        headersFetchedCount.text = ""
        headersFetchedCount.translatesAutoresizingMaskIntoConstraints = false
        headersFetchedCount.clipsToBounds = true
        // Syncing progress text
        syncProgressLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        syncProgressLabel.text = LocalizedStrings.syncingProgress
        syncProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        syncProgressLabel.clipsToBounds = true
        // block age behind
        syncProgressCount.font = UIFont(name: "Source Sans Pro", size: 14)
        syncProgressCount.text = ""
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
        
        UIView.animate(withDuration: 0.2) {
            self.latestBlockLabel.isHidden = true
            self.connectedPeersLabel.isHidden = true
        }
        
        if self.showSyncDetailsButton.isHidden == true {
            self.showSyncDetailsButton.isHidden = false
            self.showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
        }
        // Container
        let container = UIView(frame: CGRect.zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true
        //Progressbar
        let progressBar = UIProgressView(frame: CGRect.zero)
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds = true
        progressBar.progressTintColor = UIColor.init(hex: "#41be53")
        // Progress percentage
        let percentage = UILabel(frame: CGRect.zero)
        percentage.font = UIFont(name: "Source Sans Pro", size: 16.0)
        percentage.clipsToBounds = true
        // Time left
        let timeLeft = UILabel(frame: CGRect.zero)
        timeLeft.font = UIFont(name: "Source Sans Pro", size: 16.0)
        timeLeft.clipsToBounds = true
        
        container.addSubview(progressBar)
        container.addSubview(percentage)
        container.addSubview(timeLeft)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        timeLeft.translatesAutoresizingMaskIntoConstraints = false
        percentage.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            container.heightAnchor.constraint(equalToConstant: 32),//containing view start
            container.leadingAnchor.constraint(equalTo: syncProgressView.leadingAnchor, constant: 56),
            container.trailingAnchor.constraint(equalTo: syncProgressView.trailingAnchor, constant: -31),
            container.topAnchor.constraint(equalTo: syncStatusLabel.bottomAnchor, constant: 16),
            progressBar.heightAnchor.constraint(equalToConstant: 8.0),// Progress bar oonstraints start
            progressBar.widthAnchor.constraint(equalTo: container.widthAnchor),
            progressBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: container.topAnchor, constant: 1),
            percentage.heightAnchor.constraint(equalToConstant: 16),// Percentage constraints start
            percentage.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            percentage.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            timeLeft.heightAnchor.constraint(equalToConstant: 16),// Time Left constraint start
            timeLeft.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            timeLeft.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
        ]
        syncProgressView.addSubview(container)
        NSLayoutConstraint.activate(constraints)
        
        syncProgress.subscribe(with: self){ (progressReport, headersFetched) in
            guard progressReport != nil else {
                return
            }
            timeLeft.text = String(format: LocalizedStrings.syncTimeLeft, progressReport!.totalTimeRemaining)
            percentage.text = String(format: LocalizedStrings.syncProgressComplete, progressReport!.totalSyncProgress)
            progressBar.progress = Float(progressReport!.totalSyncProgress) / 100.0
        }
    }
    
    // hide sync status progressbar and time
    func hideSyncStatus() {
        if self.syncProgressView.subviews.count > 4 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.syncProgressView.subviews.last?.removeFromSuperview()
                    self.latestBlockLabel.isHidden = false
                    self.connectedPeersLabel.isHidden = false
                }
            }
            let blockAge = self.setBestBlockAge()
            let bestBlock = AppDelegate.walletLoader.wallet!.getBestBlock()
            self.latestBlockLabel.text = String(format: LocalizedStrings.latestBlockAge, bestBlock, blockAge)
            self.showSyncDetailsButton.isHidden = true
        }else{
            return
        }
        let blockAge = self.setBestBlockAge()
        let bestBlock = AppDelegate.walletLoader.wallet!.getBestBlock()
        self.latestBlockLabel.text = String(format: LocalizedStrings.latestBlockAge, bestBlock, blockAge)
        self.showSyncDetailsButton.isHidden = true
        self.updateRecentActivity()
    }
    
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
        if self.syncStatusSection.arrangedSubviews.indices.contains(2) {
            UIView.animate(withDuration: 4.3){
                self.syncStatusSection.arrangedSubviews[2].removeFromSuperview()
            }
        }
        showSyncDetailsButton.setTitle(LocalizedStrings.showDetails, for: .normal)
    }
    
    // Sync details view
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
        stepDetailLabel.text = ""
        stepDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        stepDetailLabel.clipsToBounds = true
        // fetched headers text
        headersFetchedLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        headersFetchedLabel.text = LocalizedStrings.blockHeadersFetched
        headersFetchedLabel.translatesAutoresizingMaskIntoConstraints = false
        headersFetchedLabel.clipsToBounds = true
        // Fetched headers count
        headersFetchedCount.font = UIFont(name: "Source Sans Pro", size: 14)
        headersFetchedCount.text = ""
        headersFetchedCount.translatesAutoresizingMaskIntoConstraints = false
        headersFetchedCount.clipsToBounds = true
        // Syncing progress text
        syncProgressLabel.font = UIFont(name: "Source Sans Pro", size: 14)
        syncProgressLabel.text = LocalizedStrings.syncingProgress
        syncProgressLabel.translatesAutoresizingMaskIntoConstraints = false
        syncProgressLabel.clipsToBounds = true
        // block age behind
        syncProgressCount.font = UIFont(name: "Source Sans Pro", size: 14)
        syncProgressCount.text = ""
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
        detailsView.addSubview(headersFetchedCount) // %headersFetched% of %total haeader%
        detailsView.addSubview(syncProgressLabel) // Syncing progress
        detailsView.addSubview(syncProgressCount) // days behind count
        detailsView.addSubview(numberOfPeersLabel) // Connected peers count label
        detailsView.addSubview(numberOfPeersCount) // number of connected peers
        
        let detailsViewConstraints = [
            detailsView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 46),
            detailsView.heightAnchor.constraint(equalToConstant: 112),
            detailsView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -20),
            detailsView.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 16),
            detailsView.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -16),
            headersFetchedLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            headersFetchedLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 17),
            headersFetchedLabel.heightAnchor.constraint(equalToConstant: 16),
            headersFetchedCount.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            headersFetchedCount.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 17),
            headersFetchedCount.heightAnchor.constraint(equalToConstant: 14),
            
            syncProgressLabel.heightAnchor.constraint(equalToConstant: 16),
            syncProgressLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            syncProgressLabel.topAnchor.constraint(equalTo: headersFetchedLabel.bottomAnchor, constant: 18),
            syncProgressCount.topAnchor.constraint(equalTo: headersFetchedCount.bottomAnchor, constant: 16),
            syncProgressCount.heightAnchor.constraint(equalToConstant: 16),
            syncProgressCount.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            
            numberOfPeersLabel.heightAnchor.constraint(equalToConstant: 16),
            numberOfPeersLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 16),
            numberOfPeersLabel.topAnchor.constraint(equalTo: syncProgressLabel.bottomAnchor, constant: 18),
            numberOfPeersCount.topAnchor.constraint(equalTo: syncProgressCount.bottomAnchor, constant: 16),
            numberOfPeersCount.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -16),
            numberOfPeersCount.heightAnchor.constraint(equalToConstant: 15),
            
            stepsLabel.heightAnchor.constraint(equalToConstant: 14),
            stepsLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 16),
            stepsLabel.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: 16),
            stepDetailLabel.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: 16),
            stepDetailLabel.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -16),
            stepDetailLabel.heightAnchor.constraint(equalToConstant: 16),
        ]
        
        // Add all components to superview
        detailsContainerView.addSubview(stepsLabel)
        detailsContainerView.addSubview(stepDetailLabel)
        detailsContainerView.addSubview(detailsView)
        detailsContainerView.clipsToBounds = true
        
        // Subscribe to sync status changes for use in this component
        self.syncProgress.subscribe(with: self){ (progressReport, headersFetched) in
            if progressReport != nil{
                
            }
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
        self.peers.subscribe(with: self){ (peers) in
            DispatchQueue.main.async {
                numberOfPeersCount.text = String(peers)
            }
        }
        self.syncStage.subscribe(with: self){ (stage, reportText) in
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

extension OverviewViewController: SyncProgressListenerProtocol {
    func onStarted(_ wasRestarted: Bool) {
        if (AppDelegate.walletLoader.wallet?.isSyncing() == true) {
            DispatchQueue.main.async {
                self.syncStatusImage.image = UIImage(named: "ic_syncing_24px")
                self.syncStatusLabel.text = wasRestarted ? LocalizedStrings.restartingSynchronization : LocalizedStrings.startingSynchronization
                self.syncing = true
            }
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

extension OverviewViewController: UITableViewDelegate {
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
}

extension OverviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.showAllTransactionsButton.isHidden = (self.recentTransactions.count > 3) ? false : true
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
