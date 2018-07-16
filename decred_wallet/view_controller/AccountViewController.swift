//  AccountViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

protocol  AccountDetailsCellProtocol{
    func setup(account:AccountsEntity)
}

extension AccountsData{
    init(entity:AccountsEntity, color: UIColor){
        self.color = color
        self.spendableBalance = Double((entity.Balance?.dcrSpendable)!)
        self.totalBalance = Double((entity.Balance?.dcrTotal)!)
        self.title = entity.Name
        self.isExpanded = false
    }
}

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    private lazy var myBalances: [AccountsData] = {
        let accounts = AppContext.instance.decrdConnection?.getAccounts()
        let colors = [#colorLiteral(red: 0.1807299256, green: 0.8454471231, blue: 0.6397696137, alpha: 1),#colorLiteral(red: 0.1593483388, green: 0.4376987219, blue: 1, alpha: 1),#colorLiteral(red: 0.992682755, green: 0.4418484569, blue: 0.2896475494, alpha: 1),#colorLiteral(red: 0.9992011189, green: 0.7829756141, blue: 0.3022021651, alpha: 1),#colorLiteral(red: 0.7991421819, green: 0.7997539639, blue: 0.7992369533, alpha: 1)]
        var colorCount = -1
        return accounts!.Acc.map({
            colorCount += 1
            return AccountsData(entity: $0, color: colors[colorCount])
        })
        
    }()

    @IBOutlet var tableAccountData: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableAccountData
            .hideEmptyAndExtraRows()
            .registerCellNib(AccountDataCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "Account"
    }

    func numberOfSections(in _: UITableView) -> Int {
        return myBalances.count
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AccountsHeaderView.loadNib()

        let data = myBalances[section]
        headerView.hightLithColor = data.color
        headerView.title = data.title
        headerView.totalBalance = data.totalBalance
        headerView.spendableBalance = data.spendableBalance
        headerView.headerIndex = section

        headerView.exapndOrCollapse = { [weak self] index in
            guard let strongSelf = self else { return }

            strongSelf.myBalances[index].isExpanded.toggle()
            debugPrint("expanded = \(strongSelf.myBalances[index].isExpanded)")
            strongSelf.tableAccountData.reloadData()
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myBalances[section].isExpanded == true) ? 1 : 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 540.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt rowIndex: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDataCell") as! AccountDetailsCellProtocol
        let accounts = AppContext.instance.decrdConnection?.getAccounts()
        cell.setup(account:(accounts?.Acc[rowIndex.row])!)
        return cell as! UITableViewCell
    }
}
