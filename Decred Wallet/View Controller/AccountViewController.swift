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
    
    @IBAction func amount(_ sender: Any) {
    }
    @IBAction func address(_ sender: UITextField) {
    }
    @IBAction func AccountDropdown(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
         self.navigationItem.title = "Account"
    }
}
