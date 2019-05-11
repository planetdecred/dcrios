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
    
    var currentMenuItem: MenuItem = MenuItem.overview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navMenuTableView.separatorColor = GlobalConstants.Colors.separaterGrey
        self.navMenuTableView.register(UINib(nibName: MenuCell.identifier, bundle: nil), forCellReuseIdentifier: MenuCell.identifier)
        self.navMenuTableView.dataSource = self
        self.navMenuTableView.delegate = self
        
//        self.totalBalance.text = ""
//        self.synIndicate.loadGif(name: "progress bar-1s-200px")
        
        // todo why do we need these?
//        UserDefaults.standard.set(false, forKey: "synced")
//        UserDefaults.standard.set(0, forKey: "peercount")
//        UserDefaults.standard.synchronize()
    }
}

extension NavigationMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MenuCell.height()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentMenuItem = MenuItem.allCases[indexPath.row]
        self.slideMenuController()?.changeMainViewController(self.currentMenuItem.viewController, close: true)
    }
}

extension NavigationMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItemCell = self.navMenuTableView.dequeueReusableCell(withIdentifier: MenuItemCell.identifier) as! MenuItemCell
        
        let menuItem = MenuItem.allCases[indexPath.row]
        menuItemCell.setData(menuItem)
        
        if menuItem == self.currentMenuItem {
            menuItemCell.backgroundColor = UIColor.white
            cell.lblMenu.textColor = UIColor.black
            cell.selectedView.isHidden = false
        } else {
            menuItemCell.backgroundColor = GlobalConstants.Colors.menuCell
            cell.lblMenu.textColor = GlobalConstants.Colors.menuTitle
            cell.selectedView.isHidden = true
        }
        
        return cell
    }
}

extension NavigationMenuViewController {
    static func setupMenuAndLaunchApp() {
        let navMenu = Storyboards.NavigationMenu.instantiateViewController(for: self)
        let slideMenuController = SlideMenuController(
            mainViewController: MenuItem.overview.viewController,
            leftMenuViewController: navMenu
        )
        
        AppDelegate.shared.window?.backgroundColor = GlobalConstants.Colors.lightGrey // todo necessary?
        AppDelegate.shared.setAndDisplayRootViewController(slideMenuController)
    }
}
