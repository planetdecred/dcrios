//
//  AccountSelectorDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

typealias AccountSelectorDialogCallback = (_ selectedWallet: Wallet, _ selectedAccount: DcrlibwalletAccount) -> Void

class AccountSelectorDialog: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var walletsTableView: UITableView!
    @IBOutlet weak var walletsTableViewHeightConstraint: NSLayoutConstraint!
    
    private var dialogTitle: String!
    private var callback: AccountSelectorDialogCallback!

    var wallets = [Wallet]()
    var selectedWallet: Wallet?
    var selectedAccount: DcrlibwalletAccount?

    let tableViewCellRowHeight: CGFloat = 74
    let tableViewCellSectionHeight: CGFloat = 36
    
    static func show(sender vc: UIViewController,
                     title: String,
                     selectedWallet: Wallet?,
                     selectedAccount: DcrlibwalletAccount?,
                     callback: @escaping AccountSelectorDialogCallback) {

        let dialog = AccountSelectorDialog.instantiate(from: .Receive)
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
        self.walletsTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0.1))
        self.walletsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 0.1))
        self.walletsTableView.registerCellNib(AccountSelectorTableViewCell.self)
        self.loadWallets()
        
        let rowHeightSum:CGFloat = self.wallets.reduce(0) { sum, wallet in
            sum + (CGFloat(wallet.visibleAccounts.count) * self.tableViewCellRowHeight)
        }
        let sectionHeightSum:CGFloat = (CGFloat(self.wallets.count) * self.tableViewCellSectionHeight)
        self.walletsTableViewHeightConstraint.constant = min(
            sectionHeightSum + rowHeightSum,
            UIScreen.main.bounds.height * 0.33 // max height = 1/3rd of screen height
        )
    }

    func loadWallets() {
        self.wallets = WalletLoader.shared.wallets.map({ Wallet.init($0) })
        self.walletsTableView.reloadData()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
}

extension AccountSelectorDialog: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.wallets.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableViewCellSectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: self.tableViewCellSectionHeight))
        headerView.backgroundColor = UIColor.white

        let label = UILabel()
        label.frame = CGRect.init(x: 17, y: 16, width: headerView.frame.width-8, height: 20)
        label.text = self.wallets[section].name
        label.textColor = UIColor.appColors.darkBluishGray
        label.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        headerView.addSubview(label)

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallets[section].visibleAccounts.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewCellRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountSelectorTableViewCell") as! AccountSelectorTableViewCell
        let wallet = self.wallets[indexPath.section]
        let account = wallet.visibleAccounts[indexPath.row]

        accountViewCell.account = account
        accountViewCell.checkmarkImageView.isHidden = !(wallet.name == self.selectedWallet?.name &&
                                                      account.name == self.selectedAccount?.name)
        return accountViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissView()
        self.callback(self.wallets[indexPath.section], self.wallets[indexPath.section].visibleAccounts[indexPath.row])
    }
}
