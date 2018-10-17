//
//  RecoverWalletTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018, The Decred developers
// See LICENSE for details.
//

import UIKit

class RecoverWalletTableViewController: UITableViewController {
    
    var arrSeed = Array<String>()
    var seedWords: [String?] = []
    let seedtmp = "reform aftermath printer warranty gremlin paragraph beehive stethoscope regain disruptive regain Bradbury chisel October trouble forever Algol applicant island infancy physique paragraph woodlark hydraulic snapshot backwater ratchet surrender revenge customer retouch intention minnow".split{$0 == " "}.map(String.init)
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: indexPath) as? RecoveryWalletSeedWordsCell
        cell?.setup(wordNum: indexPath.row, word: seedWords.count <= indexPath.row ? "" : seedWords[indexPath.row] ?? "", seed: seedtmp)
        cell?.onNext = {
            
        }
        return cell!
    }
   
}
