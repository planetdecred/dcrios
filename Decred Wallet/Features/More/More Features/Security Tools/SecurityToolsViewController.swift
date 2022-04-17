//
//  SecurityToolsViewController.swift
//  Decred Wallet
//
// Copyright (c)2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

class SecurityToolsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var securityToolsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.text1
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.background
           //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //setup leftBar button
        self.addNavigationBackButton()
            
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.securityTools, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.text1
            
        self.navigationItem.leftBarButtonItems =  [(self.navigationItem.leftBarButtonItem)!, barButtonTitle]
        
        //setup rightBar button
        let infoBtn = UIButton(type: .custom)
        infoBtn.setImage(UIImage(named: "ic_info"), for: .normal)
        infoBtn.addTarget(self, action: #selector(pageInfo), for: .touchUpInside)
        infoBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let infoBtnBtnItem:UIBarButtonItem = UIBarButtonItem(customView: infoBtn)
        
        self.navigationItem.rightBarButtonItem = infoBtnBtnItem
       }
    
    @objc func pageInfo() {
        SimpleAlertDialog.show(sender: self,
                               title: LocalizedStrings.securityTools,
                               message: LocalizedStrings.securityToolsInfo,
                               okButtonText: LocalizedStrings.gotIt,
                               callback: nil)
    }
       
    func navigateSecurityPage(to menuItem: SecurityToolsItem) {
        self.navigationController?.pushViewController(menuItem.viewController, animated: true)
    }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SecurityToolsItemCell.height
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigateSecurityPage(to: SecurityToolsItem.allCases[indexPath.row])
    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SecurityToolsItem.allCases.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let securityToolsItem = SecurityToolsItem.allCases[indexPath.row]
           
        let securityToolsItemCell = self.securityToolsTableView.dequeueReusableCell(withIdentifier: SecurityToolsItemCell.securityToolsIdentifier) as! SecurityToolsItemCell
        securityToolsItemCell.render(securityToolsItem)
        return securityToolsItemCell
    }
}
