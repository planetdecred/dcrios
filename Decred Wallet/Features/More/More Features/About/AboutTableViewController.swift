//
//  AboutTableViewController.swift
//  Decred Wallet

// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import JGProgressHUD
import Dcrlibwallet

class AboutTableViewController: UITableViewController {
    @IBOutlet weak var build: UILabel!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var net: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
        //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.addNavigationBackButton()
            
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.about, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.darkBlue
            
        self.navigationItem.leftBarButtonItems =  [(self.navigationItem.leftBarButtonItem)!, barButtonTitle]
        
        loadAboutData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func loadAboutData() {
        if let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            self.version?.text = "v\(versionNumber)"
        }
        
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        self.build?.text = dateformater.string(from: AppDelegate.compileDate as Date)
        
        self.net.text = BuildConfig.NetType
    }
}
