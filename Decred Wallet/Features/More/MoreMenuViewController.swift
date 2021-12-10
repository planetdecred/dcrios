//
//  MoreMenuViewController.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class MoreMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate   {
    @IBOutlet weak var moreMenuTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    func navigateMorePage(to menuItem: MoreMenuItem) {
        if menuItem == .settings {
            let settingsVC = SettingNavigationViewController(rootViewController: SettingsController.instantiate(from: .Settings))
            settingsVC.modalPresentationStyle = .currentContext
            self.present(settingsVC, animated: false, completion: nil)
        } else {
            let viewcontroller = menuItem.viewController
            if viewcontroller is PoliteiaWelcomeController {
                viewcontroller.modalPresentationStyle = .currentContext
                (viewcontroller as! PoliteiaWelcomeController).navi = self.navigationController
                self.navigationController?.navigationController?.present(viewcontroller, animated: false, completion: nil)
                return
            }
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MoreMenuItemCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateMorePage(to: MoreMenuItem.allCases[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoreMenuItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moreMenuItem = MoreMenuItem.allCases[indexPath.row]
        
        let moreMenuItemCell = self.moreMenuTableView.dequeueReusableCell(withIdentifier: MoreMenuItemCell.morMenuIdentifier) as! MoreMenuItemCell
        moreMenuItemCell.render(moreMenuItem)
        
        return moreMenuItemCell
    }
}
