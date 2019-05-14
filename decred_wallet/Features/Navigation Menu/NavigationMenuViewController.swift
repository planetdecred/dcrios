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
    
    var showNewWalletWelcomeMessage: Bool = false
    var currentMenuItem: MenuItem = MenuItem.overview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if GlobalConstants.App.IsTestnet {
            decredHeaderLogo?.image = UIImage(named: "logo-testnet")
        }
        
        self.navMenuTableView.separatorColor = GlobalConstants.Colors.separaterGrey
        self.navMenuTableView.register(UINib(nibName: MenuItemCell.identifier, bundle: nil), forCellReuseIdentifier: MenuItemCell.identifier)
        self.navMenuTableView.dataSource = self
        self.navMenuTableView.delegate = self
        
        self.totalBalanceAmountLabel.text = ""
        
        self.syncInProgressIndicator.loadGif(name: "progress bar-1s-200px")
        self.syncOperationProgressBar.progress = 0
        
        self.syncStatusLabel.text = ""
        let clickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.restartSync))
        self.syncStatusLabel.superview?.addGestureRecognizer(clickGesture)
        
        self.bestBlockLabel.text = ""
        self.bestBlockAgeLabel.text = ""
        
        self.checkSyncPermissions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !self.showNewWalletWelcomeMessage {
            return
        }
        
        self.showNewWalletWelcomeMessage = false
        self.showOkAlert(message: "\nYour 33 word seed is your wallet, keep it safe. Without it your funds cannot be recovered should your device be lost or destroyed.\n\nInitial wallet sync will take longer than usual. The wallet will connect to p2p nodes to download the blockchain headers, and will fetch only the blocks that you need while preserving your privacy.", title: "Welcome to Decred Wallet.")
    }
    
    func changeActivePage(to menuItem: MenuItem) {
        self.currentMenuItem = menuItem
        self.slideMenuController()?.changeMainViewController(self.currentMenuItem.viewController, close: true)
        self.navMenuTableView.reloadData()
    }
}

extension NavigationMenuViewController: SyncProgressListenerProtocol {
    func checkSyncPermissions() {
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
            self.syncStatusLabel.text = "Wallet not synced."
        }
        
        AppDelegate.shared.window?.rootViewController?.present(syncConfirmationController, animated: true, completion: nil)
    }

    func startSync() {
        self.syncStatusLabel.text = "Connecting to peers."
        WalletLoader.shared.syncer?.registerSyncProgressListener(for: "\(self)", self)
        WalletLoader.shared.syncer?.beginSync()
    }
    
    @objc func restartSync() {
        WalletLoader.shared.wallet?.cancelSync()
        self.startSync()
    }
    
    func onGeneralSyncProgress(_ progressReport: GeneralSyncProgressReport) {
        if !progressReport.done {
            self.syncOperationProgressBar.progress = Float(progressReport.totalSyncProgress) / 100.0
            return
        }
        
        self.syncInProgressIndicator.stopAnimating()
        self.syncInProgressIndicator.isHidden = true
        self.syncOperationProgressBar.isHidden = true
        
        self.totalBalanceAmountLabel.isHidden = false
        self.updateBalance()
        self.updateLatestBlockInfo()
        
        self.syncStatusLabel.text = "Synced with \(progressReport.peerCount) peers"
        self.syncStatusLabel.superview?.backgroundColor = UIColor(hex: "#2DD8A3")
    }
    
    func onHeadersFetchProgress(_ progressReport: HeadersFetchProgressReport) {
        self.syncStatusLabel.text = "Fetching block headers."
        if progressReport.currentHeaderTimestamp != 0 {
            self.bestBlockLabel.text = "\(progressReport.totalHeadersToFetch - progressReport.fetchedHeadersCount) blocks behind."
            if progressReport.bestBlockAge != "" {
                self.bestBlockAgeLabel.text = "\(progressReport.bestBlockAge) ago"
            }
        }
    }
    
    func onAddressDiscoveryProgress(_ progressReport: AddressDiscoveryProgressReport) {
        self.syncStatusLabel.text = "Discovering used addresses."
        self.bestBlockAgeLabel.text = ""
        
        if let generalSyncProgress = WalletLoader.shared.syncer?.generalSyncProgress {
            self.bestBlockLabel.text = "\(generalSyncProgress.totalSyncProgress)% completed, \(generalSyncProgress.totalTimeRemaining) left."
        } else {
            self.bestBlockLabel.text = ""
        }
    }
    
    func onHeadersRescanProgress(_ progressReport: HeadersRescanProgressReport) {
        self.syncStatusLabel.text = "Scanning blocks."
        self.bestBlockAgeLabel.text = ""
        
        let timeLeft = WalletLoader.shared.syncer?.generalSyncProgress?.totalTimeRemaining ?? ""
        if timeLeft != "" {
            self.bestBlockLabel.text = "\(timeLeft) left."
        } else {
            self.bestBlockLabel.text = ""
        }
    }
}

// Transaction notification callback to update best block info and balance on nav menu.
extension NavigationMenuViewController {
    struct TimeInSeconds {
        static let Minute: Int64 = 60
        static let Hour: Int64 = TimeInSeconds.Minute * 60
        static let Day: Int64 = TimeInSeconds.Hour * 24
        static let Week: Int64 = TimeInSeconds.Day * 7
        static let Month: Int64 = TimeInSeconds.Week * 4
        static let Year: Int64 = TimeInSeconds.Month * 12
    }
    
    func updateLatestBlockInfo() {
        self.bestBlockLabel.text = "Latest Block: \(WalletLoader.wallet!.getBestBlock())"
        let bestBlockAge = Int64(Date().timeIntervalSince1970.rounded() / 1000) - WalletLoader.wallet!.getBestBlockTimeStamp()
        
        switch bestBlockAge {
        case Int64.min...0:
            self.bestBlockAgeLabel.text = "now"
            
        case 0..<TimeInSeconds.Minute:
            self.bestBlockAgeLabel.text = "\(bestBlockAge)s ago"
            
        case TimeInSeconds.Minute..<TimeInSeconds.Hour:
            let minutes = bestBlockAge / TimeInSeconds.Minute
            self.bestBlockAgeLabel.text = "\(minutes)m ago"
            
        case TimeInSeconds.Hour..<TimeInSeconds.Day:
            let hours = bestBlockAge / TimeInSeconds.Hour
            self.bestBlockAgeLabel.text = "\(hours)h ago"
            
        case TimeInSeconds.Day..<TimeInSeconds.Week:
            let days = bestBlockAge / TimeInSeconds.Day
            self.bestBlockAgeLabel.text = "\(days)d ago"
            
        case TimeInSeconds.Week..<TimeInSeconds.Month:
            let weeks = bestBlockAge / TimeInSeconds.Week
            self.bestBlockAgeLabel.text = "\(weeks)w ago"
            
        case TimeInSeconds.Month..<TimeInSeconds.Year:
            let months = bestBlockAge / TimeInSeconds.Month
            self.bestBlockAgeLabel.text = "\(months)mo ago"
            
        default:
            let years = bestBlockAge / TimeInSeconds.Year
            self.bestBlockAgeLabel.text = "\(years)y ago"
        }
    }
    
    func updateBalance() {
        let totalWalletBalance = try? WalletLoader.wallet?.totalWalletBalance()
        let totalAmountRoundedOff = (Decimal(totalWalletBalance ?? 0) as NSDecimalNumber).round(8)
        self.totalBalanceAmountLabel.attributedText = Utils.getAttributedString(str: "\(totalAmountRoundedOff)", siz: 17.0, TexthexColor: GlobalConstants.Colors.TextAmount)
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

extension NavigationMenuViewController {
    static func setupMenuAndLaunchApp(isNewWallet: Bool) {
        let navMenu = Storyboards.NavigationMenu.instantiateViewController(for: self)
        navMenu.showNewWalletWelcomeMessage = isNewWallet
        
        let slideMenuController = SlideMenuController(
            mainViewController: MenuItem.overview.viewController,
            leftMenuViewController: navMenu
        )
        
        let deviceWidth = (AppDelegate.shared.window?.frame.width)!
        slideMenuController.changeLeftViewWidth(deviceWidth * 0.8)
        
        AppDelegate.shared.setAndDisplayRootViewController(slideMenuController)
    }
}
