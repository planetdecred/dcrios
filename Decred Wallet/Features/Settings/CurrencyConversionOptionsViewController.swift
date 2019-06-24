//
//  CurrencyConversionOptionsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum CurrencyConversionOption: String, CaseIterable {
    case None = "none"
    case Bittrex = "bittrex"
}

class CurrencyConversionOptionsViewController: UITableViewController {
    @IBOutlet weak var none_cell: UITableViewCell!
    @IBOutlet weak var usd_cell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch Settings.currencyConversionOption {
        case .None:
            none_cell.accessoryType = .checkmark
            none_cell.setSelected(true, animated: true)
            usd_cell.accessoryType = .none
            
        case .Bittrex:
            none_cell.accessoryType = .none
            usd_cell.accessoryType = .checkmark
            usd_cell.setSelected(true, animated: true)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LocalizedStrings.currencyConversionDesc.capitalized
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        none_cell.accessoryType = .none
        usd_cell.accessoryType = .none
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        
        let selectedOption = CurrencyConversionOption.allCases[indexPath.row]
        Settings.setValue(selectedOption.rawValue, for: Settings.Keys.CurrencyConversionOption)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
}
