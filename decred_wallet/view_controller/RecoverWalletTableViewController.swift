//
//  RecoverWalletTableViewController.swift
//  Decred Wallet
//
//  Created by Philipp Maluta on 16.10.2018.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class RecoverWalletTableViewController: UITableViewController {
    
    var arrSeed = Array<String>()
    var seedWords: String! = ""
    let seedtmp = "reform aftermath printer warranty gremlin paragraph beehive stethoscope regain disruptive regain Bradbury chisel October trouble forever Algol applicant island infancy physique paragraph woodlark hydraulic snapshot backwater ratchet surrender revenge customer retouch intention minnow"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
   
}
