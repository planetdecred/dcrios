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
    var selectedWallet: Wallet?
    var selectedAccount: DcrlibwalletAccount?

    static func show(sender vc: UIViewController,
                     title: String,
                     selectedWallet: Wallet?,
                     selectedAccount: DcrlibwalletAccount?,
                     callback: @escaping AccountSelectDialogCallback) {

        let dialog = AccountSelectDialog.instantiate(from: .Receive)
        dialog.dialogTitle = title
        dialog.callback = callback
        dialog.selectedWallet = selectedWallet
        dialog.selectedAccount = selectedAccount
        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.dialogTitle
        self.walletsTableView.hideEmptyAndExtraRows()
        self.walletsTableView.dataSource = self
        self.walletsTableView.delegate = self
        self.walletsTableView.registerCellNib(AccountSelectTableViewCell.self)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.wallets.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 20))

        let label = UILabel()
        label.frame = CGRect.init(x: 17, y: 0, width: headerView.frame.width-8, height: 14)
        label.text = self.wallets[section].name
        label.textColor = UIColor.appColors.darkBluishGray
        label.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        headerView.addSubview(label)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallets[section].accounts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountSelectTableViewCell") as! AccountSelectTableViewCell
        let wallet = self.wallets[indexPath.section]
        let account = wallet.accounts[indexPath.row]

        accountViewCell.account = account
        accountViewCell.checkmarkImageView.isHidden = !(wallet.name == self.selectedWallet?.name &&
                                                      account.name == self.selectedAccount?.name)
        return accountViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissView()
        self.callback(self.wallets[indexPath.section], self.wallets[indexPath.section].accounts[indexPath.row])
    }
}
