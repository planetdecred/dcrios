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
    @IBOutlet weak var SecurityToolsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "#091440") //move to color file
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
           //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //setup leftBar button
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.securityTools, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
               
        self.navigationItem.leftBarButtonItems =  [barButtonTitle]
        
        //setup rightBar button
        let infoBtn = UIButton(type: .custom)
        infoBtn.setImage(UIImage(named: "info"), for: .normal)
        infoBtn.addTarget(self, action: #selector(pageInfo), for: .touchUpInside)
        infoBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let infoBtnBtnItem:UIBarButtonItem = UIBarButtonItem(customView: infoBtn)
        
        self.navigationItem.rightBarButtonItem = infoBtnBtnItem
       }
    
    @objc func pageInfo(){
        let alertController = UIAlertController(title: LocalizedStrings.securityTools, message: LocalizedStrings.securityToolsInfo, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: LocalizedStrings.gotIt, style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
       
       func navigateSecurityPage(to menuItem: SecurityToolsItem) {
           //self.tabBarController?.present(menuItem.viewController, animated: true, completion: nil)
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
           
           let securityToolsItemCell = self.SecurityToolsTableView.dequeueReusableCell(withIdentifier: SecurityToolsItemCell.securityToolsIdentifier) as! SecurityToolsItemCell
           securityToolsItemCell.render(securityToolsItem)
           
           return securityToolsItemCell
       }
}
