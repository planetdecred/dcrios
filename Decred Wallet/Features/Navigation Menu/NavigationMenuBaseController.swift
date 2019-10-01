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
    var customTabBar: TabNavigationMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
        self.loadFloatingButtons() // TODO: Organize this to only show on the two pages where it is needed
        if self.isNewWallet {
            self.showOkAlert(message: LocalizedStrings.newWalletMsg)
        }
    }
    
    func loadTabBar() {
        let tabItems: [MenuItem] = [.overview, .transactions, .wallets, .more]
        
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
            self.floatingButtons.heightAnchor.constraint(equalToConstant: 48), // Fixed height for floating buttons
            self.floatingButtons.widthAnchor.constraint(equalToConstant: 240), // Fixed width for floating buttons
            self.floatingButtons.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.floatingButtons.bottomAnchor.constraint(equalTo: self.customTabBar.topAnchor, constant: -12), // position floating buttons 12pts above the nav menu
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func setupCustomTabMenu(_ menuItems: [MenuItem], completion: @escaping ([UIViewController]) -> Void) {
        let frame = tabBar.frame
        var controllers = [UIViewController]()
        
        self.customTabBar = TabNavigationMenu(items: menuItems, frame: frame) // Draw and layout the tab navigation menu
        self.customTabBar.clipsToBounds = true
        
        self.view.addSubview(customTabBar)
        self.customTabBar.translatesAutoresizingMaskIntoConstraints = false // We are setting positioning constraints in the next line. best to ignore XCode generated constraints
        
        // Add positioning constraints to place the nav menu right where the tab bar should be
        NSLayoutConstraint.activate([
            self.customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            self.customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            self.customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
            self.customTabBar.heightAnchor.constraint(equalToConstant: 67), // Fixed height for nav menu
            self.customTabBar.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
        ])
        
        for i in 0 ..< menuItems.count {
            controllers.append(menuItems[i].viewController)
        }
        
        // Custom tab bar has been created, we want to react to taps on TabNavigationMenu items the moment they happen
        // We attach a signal event listener for this and react on the main queue
        self.customTabBar.itemTapped.subscribe(with: self){ (index) in
            DispatchQueue.main.async {
                self.selectedIndex = index  // Change tabBar selected index directly to load corresponding controller
            }
        }
        tabBar.isHidden = true
        self.view.bringSubviewToFront(self.customTabBar) // Keep nav menu in front of any subviews
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
