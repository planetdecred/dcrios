//
//  NavigationMenuViewController.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 11/05/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit
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
    
    static func setupMenuAndLaunchApp(isNewWallet: Bool) {
        // wallet is open, setup sync listener and start notification listener
        WalletLoader.instance.syncer.registerEstimatedSyncProgressListener()
        WalletLoader.instance.notification.startListeningForNotifications()
        
        let navMenu = Storyboards.NavigationMenu.instantiateViewController(for: self)
        navMenu.isNewWallet = isNewWallet
        
        let slideMenuController = SlideMenuController(
            mainViewController: MenuItem.overview.viewController,
            leftMenuViewController: navMenu
        )
        
        let deviceWidth = (AppDelegate.shared.window?.frame.width)!
        slideMenuController.changeLeftViewWidth(deviceWidth * 0.8)
        
        AppDelegate.shared.setAndDisplayRootViewController(slideMenuController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GlobalConstants.App.IsTestnet {
            decredHeaderLogo?.image = UIImage(named: "logo-testnet")
        }
        
        self.navMenuTableView.separatorColor = GlobalConstants.Colors.separaterGrey
        self.navMenuTableView.register(UINib(nibName: MenuItemCell.identifier, bundle: nil), forCellReuseIdentifier: MenuItemCell.identifier)
        self.navMenuTableView.dataSource = self
        self.navMenuTableView.delegate = self
        
        let tapToRestartSyncGesture = UITapGestureRecognizer(target: self, action:  #selector(self.restartSync))
        self.syncStatusLabel.superview?.addGestureRecognizer(tapToRestartSyncGesture)
        
        if self.isNewWallet {
            self.showOkAlert(message: "\nYour 33 word seed is your wallet, keep it safe. Without it your funds cannot be recovered should your device be lost or destroyed.\n\nInitial wallet sync will take longer than usual. The wallet will connect to p2p nodes to download the blockchain headers, and will fetch only the blocks that you need while preserving your privacy.", title: "Welcome to Decred Wallet.", onPressOk: self.checkSyncPermission)
        } else {
            self.checkSyncPermission()
        }
    }
    
    func checkSyncPermission() {
        let alwaysSync = UserDefaults.standard.bool(forKey: "always_sync")
        if alwaysSync {
            self.startSync()
        } else {
            self.requestPermissionToSync()
        }
    }
    
    func requestPermissionToSync() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let syncConfirmationController = mainStoryboard.instantiateViewController(withIdentifier: "WifiSyncView") as! WifiConfirmationController
        
        syncConfirmationController.modalTransitionStyle = .crossDissolve
        syncConfirmationController.modalPresentationStyle = .overCurrentContext
        
        let tap = UITapGestureRecognizer(target: syncConfirmationController.view, action: #selector(syncConfirmationController.msgContent.endEditing(_:)))
        tap.cancelsTouchesInView = false
        
        syncConfirmationController.view.addGestureRecognizer(tap)
        
        syncConfirmationController.Always = {
            UserDefaults.standard.set(true, forKey: "always_sync")
            UserDefaults.standard.synchronize()
            self.startSync()
        }
        
        syncConfirmationController.Yes = {
            self.startSync()
        }
        
        syncConfirmationController.No = {
            self.onSyncCanceled()
        }
        
        AppDelegate.shared.window?.rootViewController?.present(syncConfirmationController, animated: true, completion: nil)
    }

    
    func resetSyncViews() {
        self.totalBalanceAmountLabel.text = ""
        
        self.syncInProgressIndicator.loadGif(name: "progress bar-1s-200px")
        self.syncInProgressIndicator.isHidden = false
        
        self.syncStatusLabel.text = ""
        self.syncStatusLabel.superview?.backgroundColor = UIColor.lightGray
        
        self.syncOperationProgressBar.progress = 0
        self.syncOperationProgressBar.isHidden = false
        
        self.bestBlockLabel.text = ""
        self.bestBlockAgeLabel.text = ""
    }
    
    func changeActivePage(to menuItem: MenuItem) {
        self.currentMenuItem = menuItem
        self.slideMenuController()?.changeMainViewController(self.currentMenuItem.viewController, close: true)
        self.navMenuTableView.reloadData()
    }
}

extension NavigationMenuViewController: SyncProgressListenerProtocol {
    func startSync() {
        self.resetSyncViews()
        self.syncStatusLabel.text = "Connecting to peers."
        WalletLoader.instance.syncer.registerSyncProgressListener(for: "\(self)", self)
        WalletLoader.instance.syncer.beginSync()
    }
    
    @objc func restartSync() {
        WalletLoader.instance.wallet?.cancelSync()
//        self.startSync()
    }
    
    func onPeerConnectedOrDisconnected(_ numberOfConnectedPeers: Int32) {
        if WalletLoader.isSynced {
            self.syncStatusLabel.text = "Synced with \(WalletLoader.instance.syncer.connectedPeers)"
        }
    }
    
    func onHeadersFetchProgress(_ progressReport: HeadersFetchProgressReport) {
        self.handleGeneralProgressReport(progressReport)
        
        self.syncStatusLabel.text = "Fetching block headers."
        if progressReport.currentHeaderTimestamp != 0 {
            self.bestBlockLabel.text = "\(progressReport.totalHeadersToFetch - progressReport.fetchedHeadersCount) blocks behind."
            if progressReport.bestBlockAge != "" {
                self.bestBlockAgeLabel.text = "\(progressReport.bestBlockAge) ago"
            }
        }
    }
    
    func onAddressDiscoveryProgress(_ progressReport: AddressDiscoveryProgressReport) {
        self.handleGeneralProgressReport(progressReport)
        
        self.syncStatusLabel.text = "Discovering used addresses."
        self.bestBlockLabel.text = "\(progressReport.totalSyncProgress)% completed, \(progressReport.totalTimeRemaining) left."
        self.bestBlockAgeLabel.text = ""
    }
    
    func onHeadersRescanProgress(_ progressReport: HeadersRescanProgressReport) {
        self.handleGeneralProgressReport(progressReport)
        
        self.syncStatusLabel.text = "Scanning blocks."
        self.bestBlockLabel.text = "\(progressReport.totalSyncProgress)% completed, \(progressReport.totalTimeRemaining) left."
        self.bestBlockAgeLabel.text = ""
    }
    
    func handleGeneralProgressReport(_ generalProgress: GeneralSyncProgressProtocol) {
        self.syncOperationProgressBar.progress = Float(generalProgress.totalSyncProgress) / 100.0
    }
    
    func onSyncCompleted() {
        self.updateBalance()
        
        self.syncInProgressIndicator.stopAnimating()
        self.syncInProgressIndicator.isHidden = true
        
        self.syncStatusLabel.text = "Synced with \(WalletLoader.instance.syncer.connectedPeers)"
        self.syncStatusLabel.superview?.backgroundColor = UIColor(hex: "#2DD8A3")
        
        self.syncOperationProgressBar.isHidden = true
        
        self.updateLatestBlockInfo()
        
        WalletLoader.instance.notification.registerListener(for: "\(self)", newBlockListener: self)
        WalletLoader.instance.notification.registerListener(for: "\(self)", newTxistener: self)
    }
    
    func onSyncCanceled() {
        self.resetSyncViews()
        self.syncStatusLabel.text = "Sync canceled. Tap to restart."
        self.syncStatusLabel.superview?.backgroundColor = UIColor.yellow
    }
    
    func onSyncEndedWithError(_ error: String) {
        self.resetSyncViews()
        self.syncStatusLabel.text = "Sync error."
        self.syncStatusLabel.superview?.backgroundColor = UIColor.red
    }
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
        
        self.bestBlockLabel.text = "Latest Block: \(WalletLoader.wallet!.getBestBlock())"
        self.setBestBlockAge()
        
        self.refreshBestBlockAgeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.setBestBlockAge()
        }
    }
    
    func setBestBlockAge() {
        let bestBlockAge = Int64(Date().timeIntervalSince1970) - WalletLoader.wallet!.getBestBlockTimeStamp()
        
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
        let totalWalletBalance = try? WalletLoader.wallet?.totalWalletBalance()
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
