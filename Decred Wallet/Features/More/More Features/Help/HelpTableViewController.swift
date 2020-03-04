//
//  HelpTableViewController.swift
//  Decred Wallet

// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import SafariServices

class HelpTableViewController: UITableViewController  {
    
    @IBOutlet weak var linkBackground: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue 
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.offWhite
        //Remove shadow from navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.help, style: .plain, target: self, action: nil)
            barButtonTitle.tintColor = UIColor.black // UIColor.appColor.darkblue
            
        self.navigationItem.leftBarButtonItems =  [barButtonTitle]
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LocalizedStrings.helpInfo
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(hex: "#3d5873")// move to color file
        header.textLabel?.text = LocalizedStrings.helpInfo
        header.textLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 16)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openLink(urlString: "https://docs.decred.org")
    }
    
    func openLink(urlString: String) {
        
        if let url = URL(string: urlString) {
            let viewController = SFSafariViewController(url: url)
            viewController.delegate = self as? SFSafariViewControllerDelegate
            
            self.present(viewController, animated: true)
        }
    }
}
