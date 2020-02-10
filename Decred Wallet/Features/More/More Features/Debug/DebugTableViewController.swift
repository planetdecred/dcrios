//
//  DebugTableViewController.swift
//  Decred Wallet

// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import JGProgressHUD
import Dcrlibwallet

class DebugTableViewController: UITableViewController  {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue 
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
        //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.addNavigationBackButton()
            
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.debug, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
            
        self.navigationItem.leftBarButtonItems =  [(self.navigationItem.leftBarButtonItem)!, barButtonTitle]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            // rescan blockchain
            self.showOkAlert(message: LocalizedStrings.rescanConfirm,
                             title: LocalizedStrings.rescanBlockchain,
                             onPressOk: self.rescanBlocks,
                             addCancelAction: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isWalletOpen = WalletLoader.shared.firstWallet?.walletOpened() ?? false
        
        switch indexPath.row {
        case 1: // rescan blockchain options, requires wallet to be opened.
            return isWalletOpen ? 44 : 0
            
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func rescanBlocks() {
        // rescan feature deprecated
    }
}
