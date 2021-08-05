//
//  AccountSelectorDialog.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

typealias AccountSelectorDialogCallback = (_ selectedAccount: DcrlibwalletAccount) -> Void

class AccountSelectorDialog: UIViewController {
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var walletsTableView: SelfSizedTableView!

    private var dialogTitle: String!
    private var callback: AccountSelectorDialogCallback!

    var wallets = [Wallet]()
    var selectedAccount: DcrlibwalletAccount?
    private var accountFilterFn: Wallet.AccountFilter?

    let accountCellRowHeight: CGFloat = 74
    let walletHeaderSectionHeight: CGFloat = 36
    
    static func show(sender vc: UIViewController,
                     title: String,
                     selectedAccount: DcrlibwalletAccount?,
                     accountFilterFn: Wallet.AccountFilter?,
                     callback: @escaping AccountSelectorDialogCallback) {

        let dialog = AccountSelectorDialog.instantiate(from: .CustomDialogs)
        dialog.dialogTitle = title
        dialog.callback = callback
        dialog.selectedAccount = selectedAccount
        dialog.accountFilterFn = accountFilterFn
        dialog.modalPresentationStyle = .pageSheet
        vc.present(dialog, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = self.dialogTitle

        self.walletsTableView.dataSource = self
        self.walletsTableView.delegate = self
        self.walletsTableView.registerCellNib(AccountSelectorTableViewCell.self)

        self.dismissViewOnTapAround()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // calculate maximum height of walletsTableView to take up
        self.walletsTableView.maxHeight = self.view.frame.size.height
            - self.headerContainerView.frame.size.height
            - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
        self.setupWalletDisplay()
    }
    
    func setupWalletDisplay() {
        self.wallets.removeAll()
        let fullCoinWallet = WalletLoader.shared.wallets
        // filter out wallets & accounts
        for wallet in fullCoinWallet {
            let wal = Wallet.init(wallet, accountsFilterFn: self.accountFilterFn)
            if wal.accounts.count > 0 {
                self.wallets.append(wal)
            }
        }
        
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
        label.textColor = UIColor.appColors.text2
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
        accountViewCell.checkmarkImageView.isHidden = account.walletID != self.selectedAccount!.walletID || account.number != self.selectedAccount!.number
        return accountViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWallet = self.wallets[indexPath.section]
        let selectedAccount = selectedWallet.accounts[indexPath.row]
        // invoke callback asynchronously to avoid delaying modal view dismissal.
        DispatchQueue.main.async {
            self.callback(selectedAccount)
        }
        
        self.dismissView()
    }
}
