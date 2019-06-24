//
//  NetworkModeTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class NetworkModeTableViewController: UITableViewController {
    @IBOutlet weak var spv_cell: UITableViewCell!
    @IBOutlet weak var remote_cell: UITableViewCell!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let networkMode = Settings.networkMode
        if networkMode == 0 {
            spv_cell.accessoryType = .checkmark
            spv_cell.setSelected(true, animated: true)
            remote_cell.accessoryType = .none
        } else if networkMode == 1 {
            spv_cell.accessoryType = .none
            remote_cell.accessoryType = .checkmark
            remote_cell.setSelected(true, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LocalizedStrings.networkModeDesc.capitalized
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        spv_cell.accessoryType = .none
        remote_cell.accessoryType = .none
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        Settings.setValue(indexPath.row, for: Settings.Keys.NetworkMode)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
}
