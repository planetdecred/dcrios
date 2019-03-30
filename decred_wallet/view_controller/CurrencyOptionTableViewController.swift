//
//  CurrencyOptionTableViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 30/03/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import UIKit

class CurrencyOptionTableViewController: UITableViewController {

    @IBOutlet weak var none_cell: UITableViewCell!
    @IBOutlet weak var usd_cell: UITableViewCell!
    let currency_value = UserDefaults.standard.integer(forKey: "currency")
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (currency_value == 0) {
            none_cell.accessoryType = .checkmark
            none_cell.setSelected(true, animated: true)
            usd_cell.accessoryType = .none
        } else if(currency_value == 1) {
            none_cell.accessoryType = .none
            usd_cell.accessoryType = .checkmark
            usd_cell.setSelected(true, animated: true)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        none_cell.accessoryType = .none
        usd_cell.accessoryType = .none
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        UserDefaults.standard.set(indexPath.row, forKey: "currency")
        UserDefaults.standard.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }

}
