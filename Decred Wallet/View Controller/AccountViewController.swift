//
//  AccountViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK:- Properties
    
    @IBOutlet weak var tableAccountData: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableAccountData
            .registerNib("AccountDataCell")
            .autoResizeCell(estimatedHeight: 100)
            .reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Account"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDataCell") as! AccountDataCell
        return cell
    }
}
