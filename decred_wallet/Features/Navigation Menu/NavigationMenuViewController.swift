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
        self.syncStatusLabel.text = ""
        self.syncOperationProgressBar.isHidden = true
        
        self.bestBlockLabel.text = ""
        self.bestBlockAgeLabel.text = ""
        
        // todo why do we need these?
//        UserDefaults.standard.set(false, forKey: "synced")
//        UserDefaults.standard.set(0, forKey: "peercount")
//        UserDefaults.standard.synchronize()
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
