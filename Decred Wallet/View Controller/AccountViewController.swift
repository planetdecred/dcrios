//
//  AccountViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class AccountViewController: UIViewController {
    //Mark Properties
    
    @IBOutlet weak var total_amount_spending:UILabel?
    @IBOutlet weak var account_name: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBAction func amount(_ sender: Any) {
    }
    @IBAction func address(_ sender: UITextField) {
    }
    @IBAction func AccountDropdown(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Example of acquaring account data
        let account = AppContext.instance.decrdConnection?.getAccounts()?.Acc.first
        total_amount_spending?.text = "\(account?.Balance?.dcrSpendable ?? 0) DCR"
        account_name.text = account?.Name
        let accountNum : Int32 = Int32((account?.Number)!)
        address.text = AppContext.instance.decrdConnection?.getCurrentAddress(account: accountNum)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Account"
    }
}
