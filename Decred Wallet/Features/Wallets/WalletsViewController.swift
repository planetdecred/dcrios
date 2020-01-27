//
//  WalletsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletsViewController: UIViewController, WalletInfoTableViewCellDelegate {
    @IBOutlet weak var walletsTableView: UITableView!
    
    var wallets = [Wallet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let walletsIterator = WalletLoader.shared.multiWallet.walletsIterator()
        while let wallet = walletsIterator!.next() {
            self.wallets.append(Wallet.init(wallet))
        }
        
        self.walletsTableView.hideEmptyAndExtraRows()
        self.walletsTableView.registerCellNib(WalletInfoTableViewCell.self)
        self.walletsTableView.dataSource = self
        self.walletsTableView.delegate = self
        self.walletsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func showWalletMenu(_ wallet: Wallet) {
        print("show wallet menu for", wallet.name)
    }
    
    func addNewAccount(_ wallet: Wallet) {
        print("add new account to", wallet.name)
    }
    
    func showAccountDetailsDialog(_ account: DcrlibwalletAccount) {
        print("show account modal for", account.name)
    }
}

extension WalletsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let wallet = self.wallets[indexPath.row]
        if !wallet.displayAccounts {
            return WalletInfoTableViewCell.walletInfoSectionHeight
        }
        
        return WalletInfoTableViewCell.walletInfoSectionHeight
            + (WalletInfoTableViewCell.accountCellHeight * CGFloat(wallet.accounts.count))
            + WalletInfoTableViewCell.addNewAccountButtonHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let walletViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletInfoTableViewCell") as! WalletInfoTableViewCell
        walletViewCell.wallet = self.wallets[indexPath.row]
        return walletViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.wallets[indexPath.row].toggleAccountsDisplay()
        tableView.reloadData()
    }
}
