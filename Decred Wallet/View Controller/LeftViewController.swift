//
//  LeftViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

enum LeftMenu: Int {
    case overview = 0
    case account
    case send
    case receive
    case history
    case settings

}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Overview", "Account", "Send", "Receive","History", "Settings"]
    var mainViewController: UIViewController!
    var swiftViewController: UIViewController!
    var sendViewController: UIViewController!
    var receiveViewController: UIViewController!
    var settingsViewController: UIViewController!
    var historyViewController: UIViewController!
    var imageHeaderView: ImageHeaderView!
    var selectedIndex: Int!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 0
        self.tableView.separatorColor = GlobalConstants.Colors.separaterGrey
        
        let storyboard =  UIStoryboard(name: "Main", bundle: nil)
        let swiftViewController = storyboard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
        self.swiftViewController = UINavigationController(rootViewController: swiftViewController)
        
        let sendViewController = storyboard.instantiateViewController(withIdentifier: "SendViewController") as! SendViewController
        self.sendViewController = UINavigationController(rootViewController: sendViewController)
        
        let goViewController = storyboard.instantiateViewController(withIdentifier: "ReceiveViewController") as! ReceiveViewController
        self.receiveViewController = UINavigationController(rootViewController: goViewController)
        
        let settingsController = storyboard.instantiateViewController(withIdentifier: "SettingsController2") as! SettingsController
        settingsController.delegate = self
        self.settingsViewController = UINavigationController(rootViewController: settingsController)
        
        let trController = TransactionHistoryViewController(nibName: "TransactionHistoryViewController", bundle: nil) as TransactionHistoryViewController!
        trController?.delegate = self
        self.historyViewController = UINavigationController(rootViewController: trController!)
        
        self.tableView.registerCellClass(MenuCell.self)
        
        self.imageHeaderView = ImageHeaderView.loadNib()
        self.view.addSubview(self.imageHeaderView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .overview:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .account:
            self.slideMenuController()?.changeMainViewController(self.swiftViewController, close: true)
        case .send:
            self.slideMenuController()?.changeMainViewController(self.sendViewController, close: true)
        case .receive:
            self.slideMenuController()?.changeMainViewController(self.receiveViewController, close: true)
        case .settings:
            self.slideMenuController()?.changeMainViewController(self.settingsViewController, close: true)
        case .history:
            self.slideMenuController()?.changeMainViewController(self.historyViewController, close: true)
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .overview, .account, .send, .receive, .history, .settings:
                return MenuCell.height()
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.selectedIndex = indexPath.row
            self.tableView.reloadData()
            self.changeViewController(menu)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .overview, .account, .send, .receive, .history, .settings:
                
                
                tableView.register(UINib(nibName: MenuCell.identifier, bundle: nil), forCellReuseIdentifier: MenuCell.identifier)
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell

                cell.setData(menus[indexPath.row])
                
                if(self.selectedIndex == indexPath.row) {
                    // cell.backView.backgroundColor = UIColor.white
                    cell.lblMenu.textColor = UIColor.black
                } else {
                    // cell.backView.backgroundColor = GlobalConstants.Colors.menuCell
                    cell.lblMenu.textColor = GlobalConstants.Colors.menuTitle
                }
                cell.selectedView.isHidden = (self.selectedIndex == indexPath.row) ? false : true
                return cell
            }
        }
        return UITableViewCell()
    }
}
