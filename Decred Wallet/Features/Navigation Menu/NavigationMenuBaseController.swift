//
//  NavigationMenuBaseController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class NavigationMenuBaseController: UITabBarController {
    
    var isNewWallet: Bool = false
    var floatingButtons: NavMenuFloatingButtons!
    var customTabBar: TabMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
        self.loadFloatingButtons() // TODO: Organize this to only show on the two pages where it is needed
        if self.isNewWallet {
            self.showOkAlert(message: LocalizedStrings.newWalletMsg)
        }
    }
    
    func loadTabBar() {
        let tabItems: [TabMenuItem] = [
            TabMenuItem(title: LocalizedStrings.overview, icon: UIImage(named: "nav_menu/ic_overview")!, controller: MenuItem.overview.viewController),
            TabMenuItem(title: LocalizedStrings.transactions, icon: UIImage(named: "nav_menu/ic_transactions")!, controller: MenuItem.transactions.viewController),
            TabMenuItem(title: LocalizedStrings.wallets, icon: UIImage(named: "nav_menu/ic_accounts")!, controller: MenuItem.accounts.viewController),
            TabMenuItem(title: LocalizedStrings.more, icon: UIImage(named: "nav_menu/ic_menu")!, controller: MenuItem.more.viewController),
        ]
        
        self.setupCustomTabMenu(tabItems){ (controllers) in
            self.viewControllers = controllers
        }
        self.selectedIndex = 0
    }
    
    public func loadFloatingButtons() {
        self.floatingButtons = NavMenuFloatingButtons()
        self.floatingButtons.translatesAutoresizingMaskIntoConstraints = false
        self.floatingButtons.clipsToBounds = true
        
        self.view.addSubview(self.floatingButtons)
        let constraints = [
            self.floatingButtons.heightAnchor.constraint(equalToConstant: 48),
            self.floatingButtons.widthAnchor.constraint(equalToConstant: 240),
            self.floatingButtons.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            self.floatingButtons.bottomAnchor.constraint(equalTo: customTabBar.topAnchor, constant: -12),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupCustomTabMenu(_ withItems: [TabMenuItem], completion: @escaping ([UIViewController]) -> Void) {
        let frame = tabBar.frame
        var controllers = [UIViewController]()
        
        self.customTabBar = TabMenu(items: withItems, frame: frame)
        self.customTabBar.clipsToBounds = true
        
        view.addSubview(customTabBar)
        self.customTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
            customTabBar.heightAnchor.constraint(equalToConstant: 67),
            customTabBar.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
        ])
        
        for i in 0 ..< withItems.count {
            controllers.append(withItems[i].controller)
        }
        
        self.customTabBar.itemTapped.subscribe(with: self){ (index) in
            DispatchQueue.main.async {
                self.selectedIndex = index
            }
        }
        tabBar.isHidden = true
        self.view.bringSubviewToFront(self.customTabBar)
        self.view.layoutIfNeeded()
        completion(controllers)
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
