//  AccountViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

protocol AccountDetailsCellProtocol {
    func setup(account: WalletAccount)
    
}

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    
    var accountHeaders: [AccountHeader] = [AccountHeader]()
    var account: WalletAccounts?
    var visible = false
    
    @IBOutlet var tableAccountData: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableAccountData
            .hideEmptyAndExtraRows()
            .registerCellNib(AccountDataCell.self)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAccount))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = LocalizedStrings.wallets
        
        self.navigationItem.rightBarButtonItem?.accessibilityElementsHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
        self.navigationItem.rightBarButtonItem?.accessibilityElementsHidden = false
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
    
    @objc func addAccount() {
        let storyboard2 =  UIStoryboard(name: "Main", bundle: nil)
        let switchView = storyboard2.instantiateViewController(withIdentifier: "addaccount")
        DispatchQueue.main.async {
            self.present(switchView, animated: true, completion: nil)
        }
    }
    
    func prepareData() {
        if !isViewLoaded || !visible {
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let this = self else { return }
            this.account?.Acc.removeAll()
            this.accountHeaders.removeAll()
            do {
                var getAccountError: NSError?
                let strAccount = AppDelegate.walletLoader.wallet?.getAccounts(0, error: &getAccountError)
                if getAccountError != nil {
                    throw getAccountError!
                }
                
                this.account = try JSONDecoder().decode(WalletAccounts.self, from: (strAccount?.data(using: .utf8))!)
                this.accountHeaders = {
                    var colorCount = -1
                    return this.account!.Acc.map {
                        colorCount += 1
                        return AccountHeader(entity: $0, color: nil)
                    }
                }()
            } catch let error {
                print(error)
            }
            
            DispatchQueue.main.async {
                this.tableAccountData.reloadData()
            }
        }
    }
    
    func numberOfSections(in _: UITableView) -> Int {
        return accountHeaders.count
    }
    
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AccountsHeaderView.loadNib()
        let accountInfo = accountHeaders[section]
        if !accountInfo.isHidden {
            headerView.title = accountInfo.title
            headerView.sethidden(status: false)
            headerView.backgroundColor = UIColor(hex: "#000000")
        } else {
            headerView.sethidden(status: true)
            headerView.title = accountInfo.title.appending(" (\(LocalizedStrings.hidden))")
            headerView.backgroundColor = UIColor(hex: "#FFFFFF")
        }
        headerView.totalBalance = accountInfo.totalBalance
        headerView.spendableBalance = accountInfo.spendableBalance
        headerView.headerIndex = section
        headerView.expandOrCollapseDetailsButton.tag = section
        headerView.arrobool = accountInfo.isExpanded
        headerView.expandOrCollapseDetailsButton.addTarget(self,action:#selector(toggleExpandedState(_:)),for: .touchUpInside)
   
        if !accountInfo.isExpanded {
            headerView.arrowDirection.setImage(UIImage.init(named: "arrow"), for: .normal)
        } else {
            headerView.arrowDirection.setImage(UIImage.init(named: "arrow-1"), for: .normal)
        }
        headerView.syncing(status: !AppDelegate.walletLoader.isSynced)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (accountHeaders[section].isExpanded == true) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let acct = account?.Acc[indexPath.section]
        if acct?.Balance?.ImmatureReward == 0 && acct?.Balance?.LockedByTickets == 0 &&
            acct?.Balance?.VotingAuthority == 0 && acct?.Balance?.ImmatureStakeGeneration == 0 {
                return 330
        }
        
        return 540.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt rowIndex: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountDataCell") as! AccountDetailsCellProtocol
        let accTmp = account!.Acc[rowIndex.section]
        cell.setup(account: (accTmp))
        
        return cell as! UITableViewCell
    }
    
    @objc private func toggleExpandedState(_ sender: UIButton) {
        accountHeaders[sender.tag].isExpanded = !accountHeaders[sender.tag].isExpanded
        tableAccountData.reloadData()
    }
}
