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
    case settings
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Overview", "Account", "Send", "Receive", "Settings"]
    var mainViewController: UIViewController!
    var swiftViewController: UIViewController!
    var sendViewController: UIViewController!
    var receiveViewController: UIViewController!
    var settingsViewController: UIViewController!
    var imageHeaderView: ImageHeaderView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.tableView.registerCellClass(BaseTableViewCell.self)
        
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
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .overview, .account, .send, .receive, .settings:
                return BaseTableViewCell.height()
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.row) {
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
            case .overview, .account, .send, .receive, .settings:
                let cell = BaseTableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: BaseTableViewCell.identifier)
                cell.setData(menus[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
}
