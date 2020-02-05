//
//  AccountSelectDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

typealias AccountSelectDialogCallback = (_ selectedWallet: Wallet, _ selectedAccount: DcrlibwalletAccount) -> Void

class AccountSelectDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var walletsTableView: UITableView!
    
    private var dialogTitle: String!
    private var callback: AccountSelectDialogCallback!

    var wallets = [Wallet]()

    static func show(sender vc: UIViewController,
                     title: String,
                     callback: @escaping AccountSelectDialogCallback) {

        let dialog = AccountSelectDialog.instantiate(from: .Receive)
        dialog.dialogTitle = title
        dialog.callback = callback

        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.dialogTitle
        self.walletsTableView.hideEmptyAndExtraRows()
        self.walletsTableView.dataSource = self
        self.walletsTableView.delegate = self
        self.walletsTableView.registerCellNib(WalletInfoTableViewCell.self)
        self.loadWallets()
    }

    func loadWallets() {
        self.wallets = WalletLoader.shared.wallets.map({ Wallet.init($0) })
        self.walletsTableView.reloadData()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
}


extension AccountSelectDialog: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let wallet = self.wallets[indexPath.row]
        var cellHeight = WalletInfoTableViewCell.walletInfoSectionHeight
        
        if !wallet.isSeedBackedUp {
            cellHeight += WalletInfoTableViewCell.walletNotBackedUpLabelHeight
                + WalletInfoTableViewCell.seedBackupPromptHeight
        }
        
        if wallet.displayAccounts {
            cellHeight += (WalletInfoTableViewCell.accountCellHeight * CGFloat(wallet.accounts.count))
                + WalletInfoTableViewCell.addNewAccountButtonHeight
        }
        
        return cellHeight
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
