//
//  TransactionHistoryViewController.swift
//  Decred Wallet
//
//  Created by rails on 23/05/18.
//  Copyright © 2018 The Decred developers. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: UIViewController {
    weak var delegate: LeftMenuProtocol?

    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnFilter: DropMenuButton!

    var dic1 = ["status": "Pending", "type": "Credit", "amount": "112.000000 DCR", "date": "23 Mar, 2018 10:30 pm"] as Dictionary!
    var dic2 = ["status": "Confirmed", "type": "Debit", "amount": "24.000000 DCR", "date": "23 Mar, 2018 10:30 pm"] as Dictionary!
    var dic3 = ["status": "Confirmed", "type": "Debit", "amount": "26.000000 DCR", "date": "23 Mar, 2018 10:30 pm"] as Dictionary!
    var dic4 = ["status": "Confirmed", "type": "Debit", "amount": "72.000000 DCR", "date": "23 Mar, 2018 10:30 pm"] as Dictionary!
    var dic5 = ["status": "Confirmed", "type": "Credit", "amount": "92.000000 DCR", "date": "23 Mar, 2018 10:30 pm"] as Dictionary!

    let filterMenu = ["ALL", "Regular", "Ticket", "Votes", "Revokes", "Sent"] as [String]

    var mainContens = [Dictionary<String, String>]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mainContens.append(dic1!)
        mainContens.append(dic2!)
        mainContens.append(dic3!)
        mainContens.append(dic4!)
        mainContens.append(dic5!)

        btnFilter.initMenu(filterMenu) { index, value in
            print("index : \(index), Value : \(value)")
        }

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "History"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Table Delegates

extension TransactionHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return mainContens.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TransactionHistoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TransactionHistoryTableViewCell.identifier)
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as! TransactionHistoryTableViewCell

        let data = TransactionTableViewCellData(data: mainContens[indexPath.row])
        cell.setData(data)

        cell.backgroundColor = AppDelegate.shared.theme.backgroundColor
        cell.contentView.backgroundColor = AppDelegate.shared.theme.backgroundColor

        return cell
    }
}
