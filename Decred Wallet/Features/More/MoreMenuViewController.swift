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
        let barButtonImg = UIBarButtonItem(image: UIImage(named: "ic_decred")?.withRenderingMode(.alwaysOriginal),
        style: .done, target: self,
        action: nil)
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.more, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.darkBlue
        let positiveSeparator = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        positiveSeparator.width = 16
       
        self.navigationItem.leftBarButtonItems = [positiveSeparator, barButtonImg, barButtonTitle]
    
        //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func navigateMorePage(to menuItem: MoreMenuItem) {
        self.navigationController?.pushViewController(menuItem.viewController, animated: true)
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
