//
//  NavigationMenuBaseController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class NavigationMenuBaseController: TabMenuController {
    
    var isNewWallet: Bool = false
    var floatinButtons: FloatingButtons!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
        self.loadFloatingButtons() // TODO: Organize this to only show on the two pages where it is needed
        if self.isNewWallet{
            self.showOkAlert(message: LocalizedStrings.newWalletMsg)
        }
    }
    
    func loadTabBar(){
        let tabItems: [TabMenuItem] = [
            TabMenuItem(title: LocalizedStrings.overview, icon: UIImage(named: "menu/overview")!, controller: MenuItem.overview.viewController),
            TabMenuItem(title: LocalizedStrings.transactions, icon: UIImage(named: "menu/transactions")!, controller: MenuItem.transactions.viewController),
            TabMenuItem(title: LocalizedStrings.wallets, icon: UIImage(named: "menu/accounts")!, controller: MenuItem.accounts.viewController),
            TabMenuItem(title: LocalizedStrings.more, icon: UIImage(named: "menu/more")!, controller: MenuItem.more.viewController),
        ]
        
        setupCustomTabMenu(tabItems) { (controllers) in
            self.viewControllers = controllers
            self.selectedIndex = 0
        }
        // We can now listen for tab bar item taps and react
        customTabBar.itemTapped.subscribe(with: self){ (index) in
            DispatchQueue.main.async {
                self.selectedIndex = index
            }
        }
    }
    
    public func loadFloatingButtons( ){
        self.floatinButtons = FloatingButtons()
        self.floatinButtons.translatesAutoresizingMaskIntoConstraints = false
        self.floatinButtons.clipsToBounds = true
        
        self.view.addSubview(floatinButtons)
        let constraints = [
            self.floatinButtons.heightAnchor.constraint(equalToConstant: 48),
            self.floatinButtons.widthAnchor.constraint(equalToConstant: 240),
            self.floatinButtons.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            self.floatinButtons.bottomAnchor.constraint(equalTo: customTabBar.topAnchor, constant: -12),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    static func setupMenuAndLaunchApp(isNewWallet: Bool) {
        // wallet is open, setup sync listener and start notification listener
        AppDelegate.walletLoader.syncer.registerEstimatedSyncProgressListener()
        AppDelegate.walletLoader.notification.startListeningForNotifications()
        
        let startView = NavigationMenuBaseController()
        startView.isNewWallet = isNewWallet
        AppDelegate.shared.setAndDisplayRootViewController(startView)
    }
}
