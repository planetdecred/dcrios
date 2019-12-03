//
//  ConfirmToSendViewCotroller.swift
//  Decred Wallet
//
//  Created by kayeli dennis on 03/12/2019.
//  Copyright © 2019 Decred. All rights reserved.
//

import UIKit

class ConfirmToSendViewCotroller: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCellNib(SimpleInfoTableViewCell.self)
        tableView.registerCellNib(ModalNavBarCell.self)
        tableView.registerCellNib(SendingInfoTableViewCell.self)
        tableView.registerCellNib(WarningInfoTableViewCell.self)
    }
    
    @IBAction func send(_ sender: UIButton) {
    }
}

extension ConfirmToSendViewCotroller: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ModalNavBarCell", for: indexPath) as? ModalNavBarCell
        } else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SendingInfoTableViewCell", for: indexPath) as? SendingInfoTableViewCell
        } else if indexPath.row == 2 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
        } else if indexPath.row == 3 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
        }
        else if indexPath.row == 4 {
            cell = tableView.dequeueReusableCell(withIdentifier: "SimpleInfoTableViewCell", for: indexPath) as? SimpleInfoTableViewCell
        } else if indexPath.row == 5 {
            cell = tableView.dequeueReusableCell(withIdentifier: "WarningInfoTableViewCell", for: indexPath) as? WarningInfoTableViewCell
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 170 : 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
}
