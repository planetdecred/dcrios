//  AccountViewController.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

import Foundation
import UIKit

protocol AccountDetailsCellProtocol {
    func setup(account: AccountsEntity)
    
}

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties

    var myBalances: [AccountsData] = [AccountsData]()
    var account: GetAccountResponse?
    var visible = false

    @IBOutlet var tableAccountData: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("account loaded")
        tableAccountData
            .hideEmptyAndExtraRows()
            .registerCellNib(AccountDataCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarItem()
        navigationItem.title = "Account"
        print("account will appear")
        // self.account = AppContext.instance.decrdConnection?.getAccounts()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
        
        // self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("disposing mem")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visible = true
        prepareData()
    }

    func prepareData() {
        if !isViewLoaded {
            return
        }
        if visible == false {
            return
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let this = self else { return }
            this.account?.Acc.removeAll()
            this.myBalances.removeAll()
            do {
                let strAccount = try SingleInstance.shared.wallet?.getAccounts(0)
                this.account = try JSONDecoder().decode(GetAccountResponse.self, from: (strAccount?.data(using: .utf8))!)
                this.myBalances = {
                    // let colors = [#colorLiteral(red: 0.1807299256, green: 0.8454471231, blue: 0.6397696137, alpha: 1), #colorLiteral(red: 0.1593483388, green: 0.4376987219, blue: 1, alpha: 1), #colorLiteral(red: 0.992682755, green: 0.4418484569, blue: 0.2896475494, alpha: 1), #colorLiteral(red: 0.9992011189, green: 0.7829756141, blue: 0.3022021651, alpha: 1), #colorLiteral(red: 0.7991421819, green: 0.7997539639, blue: 0.7992369533, alpha: 1)]
                    var colorCount = -1
                    return this.account!.Acc.map {
                        colorCount += 1
                        return AccountsData(entity: $0, color: nil)
                    }

                }()
            } catch let error {
                print(error)
            }

            DispatchQueue.main.async {
                print("refreshing list")
                this.tableAccountData.reloadData()
            }
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        print("account returning number of section")
        return myBalances.count
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AccountsHeaderView.loadNib()
        print("account inputing headerView data")
        let data = myBalances[section]
        headerView.title = data.title
        headerView.totalBalance = data.totalBalance
        headerView.spendableBalance = data.spendableBalance
        headerView.headerIndex = section
        headerView.expandOrCollapseDetailsButton.tag = section
        headerView.arrobool = data.isExpanded
        headerView.expandOrCollapseDetailsButton.addTarget(
            self,
            action: #selector(toggleExpandedState(_:)),
            for: .touchUpInside
        )
        if !(data.isExpanded){
            headerView.arrowDirection.setImage(UIImage.init(named: "arrow"), for: .normal)
        }
        else{
            headerView.arrowDirection.setImage(UIImage.init(named: "arrow-1"), for: .normal)
        }

        print("account returning header view")
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
        print("account creating cells")
        cell.setup(account: (account!.Acc[rowIndex.row]))
       
        return cell as! UITableViewCell
    }

    @objc private func toggleExpandedState(_ sender: UIButton) {
        myBalances[sender.tag].isExpanded.toggle()
        tableAccountData.reloadData()
    }
}
