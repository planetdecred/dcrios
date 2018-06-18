//  AccountViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK:- Properties
    
    private lazy var myBalances: [AccountsData] = {
        let ac1 = AccountsData.init(
            color: #colorLiteral(red: 0.1807299256, green: 0.8454471231, blue: 0.6397696137, alpha: 1),
            spendableBalance: 153.80078,
            title: "My Wallet",
            totalBalance: 258.58087
        )
        
        let ac2 = AccountsData.init(
            color: #colorLiteral(red: 0.1593483388, green: 0.4376987219, blue: 1, alpha: 1),
            spendableBalance: 102.14870,
            title: "ASICs Mining",
            totalBalance: 105.22705
        )
        
        let ac3 = AccountsData.init(
            color: #colorLiteral(red: 0.992682755, green: 0.4418484569, blue: 0.2896475494, alpha: 1),
            spendableBalance: 200.0,
            title: "Savings",
            totalBalance: 5000.0
        )
        
        let ac4 = AccountsData.init(
            color: #colorLiteral(red: 0.9992011189, green: 0.7829756141, blue: 0.3022021651, alpha: 1),
            spendableBalance: 200.0,
            title: "Imported",
            totalBalance: 1000.0
        )
        
        let ac5 = AccountsData.init(
            color: #colorLiteral(red: 0.7991421819, green: 0.7997539639, blue: 0.7992369533, alpha: 1),
            spendableBalance: 200.0,
            title: "Mining (Hidden)",
            totalBalance: 1000.0
        )
        
        return [ac1, ac2, ac3, ac4, ac5]
    }()
    
    @IBOutlet weak var tableAccountData: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableAccountData
            .autoResizeCell(estimatedHeight: 100)
            .hideEmptyAndExtraRows()
            .registerCellNib(AccountDataCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        self.navigationItem.title = "Account"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myBalances.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDataCell") as! AccountDataCell
        
        let data = myBalances[indexPath.row]
        cell.hightLithColor = data.color
        cell.title = data.title
        cell.totalBalance = data.totalBalance
        cell.spendableBalance = data.spendableBalance
        
        return cell
    }
}
