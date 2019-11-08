//
//  NavigationMenuTabBarController.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class NavigationMenuTabBarController: UITabBarController {
    
    var isNewWallet: Bool = false
    var customTabBar: CustomTabMenuView!
    lazy var floatingButtons: NavMenuFloatingButtons = {
        return NavMenuFloatingButtons()
    }()
    let sync = SyncManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
        if self.isNewWallet {
            self.showOkAlert(message: LocalizedStrings.newWalletMsg)
        }
    }
    
    func loadTabBar() {
        let tabItems: [MenuItem] = [.overview, .transactions, .wallets, .more]
        self.setupCustomTabMenu(tabItems)
        self.selectedIndex = 0
    }
    
    // Create our custom menu bar and display it right where the tab bar should be.
    func setupCustomTabMenu(_ menuItems: [MenuItem]) {
        tabBar.isHidden = true
        
        let background = UIView(frame: CGRect.zero) // White background to fill up safe area at bottom of devices >= iPhone X
        background.backgroundColor = UIColor.white
        background.translatesAutoresizingMaskIntoConstraints = false
        background.clipsToBounds = true
        self.view.addSubview(background)
                
        self.customTabBar = CustomTabMenuView(menuItems: menuItems, frame: tabBar.frame) // Draw and layout the tab navigation menu
        self.customTabBar.translatesAutoresizingMaskIntoConstraints = false // We are setting positioning constraints in the next line. best to ignore XCode generated constraints
        self.customTabBar.clipsToBounds = true
        self.view.addSubview(self.customTabBar)
        
        // Positioning constraints to place the nav menu right where the tab bar should be
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            background.heightAnchor.constraint(equalToConstant: tabBar.frame.size.height),
            
            self.customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            self.customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            self.customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
            self.customTabBar.heightAnchor.constraint(equalToConstant: 56), // Fixed height of 56pts for nav menu from mockup. This value does not include the curved edge insets in devices >= iPhone X
            self.customTabBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Custom tab bar has been created, we want to react to taps on TabNavigationMenu items the moment they happen
        self.customTabBar.itemTapped = { index in
            self.selectedIndex = index
            if index == 0 {
                self.showFloatingButtons()
            } else {
                self.hideFloatingButtons()
            }
        }
        self.viewControllers = menuItems.map({ $0.viewController })
        
        self.view.bringSubviewToFront(self.customTabBar) // Keep nav menu in front of any subviews
        self.view.layoutIfNeeded()
    }
    
    public func showFloatingButtons() {
        self.floatingButtons.translatesAutoresizingMaskIntoConstraints = false
        self.floatingButtons.clipsToBounds = true
        self.floatingButtons.layer.shadowColor = UIColor(red: 0.16, green: 0.44, blue: 1.0, alpha: 1).cgColor
        self.floatingButtons.layer.shadowOpacity = 0.16
        self.floatingButtons.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.floatingButtons.layer.masksToBounds = false
        
        self.view.addSubview(self.floatingButtons)
        let constraints = [
            self.floatingButtons.heightAnchor.constraint(equalToConstant: 48), // Fixed height for floating buttons
            self.floatingButtons.widthAnchor.constraint(equalToConstant: 240), // Fixed width for floating buttons
            self.floatingButtons.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.floatingButtons.bottomAnchor.constraint(equalTo: self.customTabBar.topAnchor, constant: -12), // position floating buttons 12pts above the nav menu
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    public func hideFloatingButtons() {
        // Do nothing if the floating buttons are not on the view heirachy.
        guard self.view.subviews.firstIndex(of: self.floatingButtons) != nil else {
            return
        }
        self.floatingButtons.removeFromSuperview() // Remove floating buttons
    }
    
    static func setupMenuAndLaunchApp(isNewWallet: Bool) {
        // wallet is open, setup sync listener and start notification listener
        AppDelegate.walletLoader.syncer.registerEstimatedSyncProgressListener()
        AppDelegate.walletLoader.notification.startListeningForNotifications()
        
        let startView = NavigationMenuTabBarController()
        startView.isNewWallet = isNewWallet
        AppDelegate.shared.setAndDisplayRootViewController(startView)
    }
}
