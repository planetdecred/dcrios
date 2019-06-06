//
//  NavigationMenuViewController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 11/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit
import Dcrlibwallet
import SlideMenuControllerSwift

class NavigationMenuViewController: UIViewController {
    @IBOutlet weak var decredHeaderLogo: UIImageView!
    @IBOutlet weak var navMenuTableView: UITableView!
    
    @IBOutlet weak var totalBalanceAmountLabel: UILabel!
    
    @IBOutlet weak var syncInProgressIndicator: UIImageView!
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var syncOperationProgressBar: UIProgressView!
    
    @IBOutlet weak var bestBlockLabel: UILabel!
    @IBOutlet weak var bestBlockAgeLabel: UILabel!
    var refreshBestBlockAgeTimer: Timer?
    
    var isNewWallet: Bool = false
    var currentMenuItem: MenuItem = MenuItem.overview
    
    var restartSyncTriggered: Bool = false
    
    static func setupMenuAndLaunchApp(isNewWallet: Bool) {
        // wallet is open, setup sync listener and start notification listener
        AppDelegate.walletLoader.syncer.registerEstimatedSyncProgressListener()
        AppDelegate.walletLoader.notification.startListeningForNotifications()
        
        let navMenu = Storyboards.NavigationMenu.instantiateViewController(for: self)
        navMenu.isNewWallet = isNewWallet
        
        let slideMenuController = SlideMenuController(
            mainViewController: MenuItem.overview.viewController,
            leftMenuViewController: navMenu
        )
        
        let deviceWidth = (AppDelegate.shared.window?.frame.width)!
        slideMenuController.changeLeftViewWidth(min(deviceWidth * 0.8, 300))
        
        AppDelegate.shared.setAndDisplayRootViewController(slideMenuController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BuildConfig.IsTestNet {
            decredHeaderLogo?.image = UIImage(named: "logo-testnet")
        }
        
        self.navMenuTableView.separatorColor = GlobalConstants.Colors.separaterGrey
        self.navMenuTableView.register(UINib(nibName: MenuItemCell.identifier, bundle: nil), forCellReuseIdentifier: MenuItemCell.identifier)
        self.navMenuTableView.dataSource = self
        self.navMenuTableView.delegate = self
        
        let tapToRestartSyncGesture = UITapGestureRecognizer(target: self, action:  #selector(self.restartSyncTapListener))
        self.syncStatusLabel.superview?.addGestureRecognizer(tapToRestartSyncGesture)
        
        if self.isNewWallet {
            NewWalletDialog.show(onDialogDismissed: self.checkNetworkConnectionForSync)
        } else {
            self.checkNetworkConnectionForSync()
        }
    }
    
    @objc func restartSyncTapListener() {
        self.restartSyncTriggered = true
        self.checkNetworkConnectionForSync()
    }
    
    func checkNetworkConnectionForSync() {
        // Re-trigger app network change listener to ensure correct network status is determined.
        AppDelegate.shared.listenForNetworkChanges()
        
        if AppDelegate.shared.reachability.connection == .none {
            self.showOkAlert(message: "Cannot sync without network connection.", title: "Internet connection required.", onPressOk: self.checkSyncPermission)
        } else {
            self.checkSyncPermission()
        }
    }
    
    func checkSyncPermission() {
        if AppDelegate.shared.reachability.connection == .none {
            self.syncNotStartedDueToNetwork()
        } else if AppDelegate.shared.reachability.connection == .wifi || Settings.syncOnCellular {
            self.startSync()
        } else {
            self.requestPermissionToSync()
        }
    }
    
    func requestPermissionToSync() {
        let syncConfirmationDialog = Storyboards.NavigationMenu.instantiateViewController(for: NoWifiSyncConfirmationDialog.self)
        
        syncConfirmationDialog.modalTransitionStyle = .crossDissolve
        syncConfirmationDialog.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: syncConfirmationDialog.view, action: #selector(syncConfirmationDialog.dialogContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        syncConfirmationDialog.view.addGestureRecognizer(tap)
        
        syncConfirmationDialog.No = {
            self.syncNotStartedDueToNetwork()
        }
        
        syncConfirmationDialog.Yes = {
            self.startSync()
        }
        
        syncConfirmationDialog.Always = {
            Settings.setValue(true, for: Settings.Keys.SyncOnCellular)
            self.startSync()
        }
        
        AppDelegate.shared.window?.rootViewController?.present(syncConfirmationDialog, animated: true, completion: nil)
    }
    
    func syncNotStartedDueToNetwork() {
        AppDelegate.walletLoader.syncer.deRegisterSyncProgressListener(for: "\(self)")
        AppDelegate.walletLoader.wallet?.cancelSync(false) // Cancel any previous/ongoing sync process without losing peers.
        
        // Allow 0.5 seconds for sync cancellation to complete before setting up wallet.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppDelegate.walletLoader.syncer.assumeSyncCompleted()
            self.onSyncCompleted()
            
            self.syncStatusLabel.text = "Connect to WiFi to sync."
            self.syncStatusLabel.superview?.backgroundColor = UIColor.red
        }
    }

    func resetSyncViews() {
        self.totalBalanceAmountLabel.text = ""
        
        self.syncInProgressIndicator.loadGif(name: "progress bar-1s-200px")
        self.syncInProgressIndicator.isHidden = false
        
        self.syncStatusLabel.text = ""
        self.syncStatusLabel.superview?.backgroundColor = UIColor.lightGray
        
        self.syncOperationProgressBar.progress = 0
        self.syncOperationProgressBar.isHidden = false
        
        self.bestBlockLabel.text = " " // use whitespace so view don't get 0 height
        self.bestBlockAgeLabel.text = " " // use whitespace so view don't get 0 height
    }
    
    func changeActivePage(to menuItem: MenuItem) {
        self.currentMenuItem = menuItem
        self.slideMenuController()?.changeMainViewController(self.currentMenuItem.viewController, close: true)
        self.navMenuTableView.reloadData()
    }
    
    func stopRefreshingBestBlockAge() {
            self.refreshBestBlockAgeTimer?.invalidate()
            self.refreshBestBlockAgeTimer = nil
    }
}

extension NavigationMenuViewController: SyncProgressListenerProtocol {
    func startSync() {
        AppDelegate.walletLoader.syncer.registerSyncProgressListener(for: "\(self)", self)
        
        if self.restartSyncTriggered {
            self.restartSyncTriggered = false
            self.restartSync()
        } else {
            self.resetSyncViews()
            AppDelegate.walletLoader.syncer.beginSync()
        }
    }
    
    func restartSync() {
        AppDelegate.walletLoader.syncer.restartSync()
        
        self.stopRefreshingBestBlockAge()
        
        self.resetSyncViews()
        self.syncStatusLabel.text = "Restarting sync..."
    }
    
    func onStarted() {
        self.syncStatusLabel.text = "Connecting to peers."
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        if AppDelegate.walletLoader.isSynced {
            self.syncStatusLabel.text = "Synced with \(AppDelegate.walletLoader.syncer.connectedPeers)"
        }
    }
    
    func onHeadersFetchProgress(_ progressReport: DcrlibwalletHeadersFetchProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        self.syncStatusLabel.text = "Fetching block headers."
        if progressReport.currentHeaderTimestamp != 0 {
            self.bestBlockLabel.text = "\(progressReport.totalHeadersToFetch - progressReport.fetchedHeadersCount) blocks behind."
            if progressReport.bestBlockAge != "" {
                self.bestBlockAgeLabel.text = "\(progressReport.bestBlockAge) ago"
            }
        }
    }
    
    func onAddressDiscoveryProgress(_ progressReport: DcrlibwalletAddressDiscoveryProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        self.syncStatusLabel.text = "Discovering used addresses."
        self.bestBlockLabel.text = "\(progressReport.generalSyncProgress!.totalSyncProgress)% completed, \(progressReport.generalSyncProgress!.totalTimeRemaining) left."
        self.bestBlockAgeLabel.text = ""
    }
    
    func onHeadersRescanProgress(_ progressReport: DcrlibwalletHeadersRescanProgressReport) {
        self.handleGeneralProgressReport(progressReport.generalSyncProgress!)
        
        self.syncStatusLabel.text = "Scanning blocks."
        self.bestBlockLabel.text = "\(progressReport.generalSyncProgress!.totalSyncProgress)% completed, \(progressReport.generalSyncProgress!.totalTimeRemaining) left."
        self.bestBlockAgeLabel.text = ""
    }
    
    func handleGeneralProgressReport(_ generalProgress: DcrlibwalletGeneralSyncProgress) {
        self.syncOperationProgressBar.progress = Float(generalProgress.totalSyncProgress) / 100.0
    }
    
    func onSyncCompleted() {
        self.updateBalance()
        
        self.syncInProgressIndicator.stopAnimating()
        self.syncInProgressIndicator.isHidden = true
        
        self.syncStatusLabel.text = "Synced with \(AppDelegate.walletLoader.syncer.connectedPeers)"
        self.syncStatusLabel.superview?.backgroundColor = UIColor(hex: "#2DD8A3")
        
        self.syncOperationProgressBar.isHidden = true
        
        self.updateLatestBlockInfo()
        
        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", newBlockListener: self)
        AppDelegate.walletLoader.notification.registerListener(for: "\(self)", newTxistener: self)
    }
    
    func onSyncCanceled() {
        self.resetSyncViews()
        self.syncStatusLabel.text = "Sync canceled."
    }
    
    func onSyncEndedWithError(_ error: String) {
        self.resetSyncViews()
        self.syncStatusLabel.text = "Sync error."
        self.syncStatusLabel.superview?.backgroundColor = UIColor.red
    }
    
    func debug(_ debugInfo: DcrlibwalletDebugInfo) {}
}

// Transaction notification callback to update best block info (on block attached) and balance (on new transaction).
extension NavigationMenuViewController: NewBlockNotificationProtocol, NewTransactionNotificationProtocol {
    func onBlockAttached(_ height: Int32, timestamp: Int64) {
        DispatchQueue.main.async {
            self.updateLatestBlockInfo()
        }
    }
    
    func onTransaction(_ transaction: String?) {
        DispatchQueue.main.async {
            self.updateBalance()
        }
    }
    
    func updateLatestBlockInfo() {
        if self.refreshBestBlockAgeTimer != nil {
            self.refreshBestBlockAgeTimer?.invalidate()
        }
        
        self.bestBlockLabel.text = "Latest Block: \(AppDelegate.walletLoader.wallet!.getBestBlock())"
        self.setBestBlockAge()
        
        self.refreshBestBlockAgeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.setBestBlockAge()
        }
    }
    
    func setBestBlockAge() {
        let bestBlockAge = Int64(Date().timeIntervalSince1970) - AppDelegate.walletLoader.wallet!.getBestBlockTimeStamp()
        
        switch bestBlockAge {
        case Int64.min...0:
            self.bestBlockAgeLabel.text = "now"
            
        case 0..<Utils.TimeInSeconds.Minute:
            self.bestBlockAgeLabel.text = "\(bestBlockAge)s ago"
            
        case Utils.TimeInSeconds.Minute..<Utils.TimeInSeconds.Hour:
            let minutes = bestBlockAge / Utils.TimeInSeconds.Minute
            self.bestBlockAgeLabel.text = "\(minutes)m ago"
            
        case Utils.TimeInSeconds.Hour..<Utils.TimeInSeconds.Day:
            let hours = bestBlockAge / Utils.TimeInSeconds.Hour
            self.bestBlockAgeLabel.text = "\(hours)h ago"
            
        case Utils.TimeInSeconds.Day..<Utils.TimeInSeconds.Week:
            let days = bestBlockAge / Utils.TimeInSeconds.Day
            self.bestBlockAgeLabel.text = "\(days)d ago"
            
        case Utils.TimeInSeconds.Week..<Utils.TimeInSeconds.Month:
            let weeks = bestBlockAge / Utils.TimeInSeconds.Week
            self.bestBlockAgeLabel.text = "\(weeks)w ago"
            
        case Utils.TimeInSeconds.Month..<Utils.TimeInSeconds.Year:
            let months = bestBlockAge / Utils.TimeInSeconds.Month
            self.bestBlockAgeLabel.text = "\(months)mo ago"
            
        default:
            let years = bestBlockAge / Utils.TimeInSeconds.Year
            self.bestBlockAgeLabel.text = "\(years)y ago"
        }
    }
    
    func updateBalance() {
        let totalWalletBalance = AppDelegate.walletLoader.wallet?.totalWalletBalance()
        let totalAmountRoundedOff = (Decimal(totalWalletBalance ?? 0) as NSDecimalNumber).round(8)
        self.totalBalanceAmountLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 12.0, TexthexColor: GlobalConstants.Colors.TextAmount)
    }
}

extension NavigationMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MenuItemCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.changeActivePage(to: MenuItem.allCases[indexPath.row])
    }
}

extension NavigationMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = MenuItem.allCases[indexPath.row]
        
        let menuItemCell = self.navMenuTableView.dequeueReusableCell(withIdentifier: MenuItemCell.identifier) as! MenuItemCell
        menuItemCell.render(menuItem, isCurrentItem: self.currentMenuItem == menuItem)
        
        return menuItemCell
    }
}
