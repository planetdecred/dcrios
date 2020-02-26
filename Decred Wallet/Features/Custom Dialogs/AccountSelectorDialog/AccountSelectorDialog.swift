//
//  AccountSelectorDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

typealias AccountSelectorDialogCallback = (_ selectedWalletId: Int, _ selectedAccount: DcrlibwalletAccount) -> Void

class AccountSelectorDialog: UIViewController {
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var walletsTableView: SelfSizedTableView!

    private var dialogTitle: String!
    private var callback: AccountSelectorDialogCallback!

    var wallets = [Wallet]()
    var selectedWallet: DcrlibwalletWallet?
    var selectedAccount: DcrlibwalletAccount?

    let accountCellRowHeight: CGFloat = 74
    let walletHeaderSectionHeight: CGFloat = 36
    
    static func show(sender vc: UIViewController,
                     title: String,
                     selectedWallet: DcrlibwalletWallet?,
                     selectedAccount: DcrlibwalletAccount?,
                     callback: @escaping AccountSelectorDialogCallback) {

        let dialog = AccountSelectorDialog.instantiate(from: .CustomDialogs)
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

        self.walletsTableView.dataSource = self
        self.walletsTableView.delegate = self
        self.walletsTableView.registerCellNib(AccountSelectorTableViewCell.self)

        let accountsFilterFn: (DcrlibwalletAccount) -> Bool = { $0.totalBalance > 0 || $0.name != "imported" }
        self.wallets = WalletLoader.shared.wallets.map({ Wallet.init($0, accountsFilterFn: accountsFilterFn) })
        self.walletsTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // calculate maximum height of walletsTableView to take up
        self.walletsTableView.maxHeight = self.view.frame.size.height
            - self.headerContainerView.frame.size.height
            - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
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
        return self.walletHeaderSectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = Label(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: self.walletHeaderSectionHeight))
        label.leftPadding = 17
        label.topPadding = 16
        label.borderWidth = 0
        label.text = self.wallets[section].name
        label.textColor = UIColor.appColors.darkBluishGray
        label.backgroundColor = UIColor.white
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        return label
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wallets[section].accounts.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.accountCellRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountViewCell = tableView.dequeueReusableCell(withIdentifier: "AccountSelectorTableViewCell") as! AccountSelectorTableViewCell
        let wallet = self.wallets[indexPath.section]
        let account = wallet.accounts[indexPath.row]
        accountViewCell.account = account
        accountViewCell.checkmarkImageView.isHidden = wallet.name != self.selectedWallet?.name || account.name != self.selectedAccount?.name
        return accountViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissView()
        self.callback(self.wallets[indexPath.section].id, self.wallets[indexPath.section].accounts[indexPath.row])
    }
}
