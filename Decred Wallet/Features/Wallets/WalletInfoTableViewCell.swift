//
//  WalletInfoTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

protocol WalletInfoTableViewCellDelegate {
    func showWalletMenu(walletName: String, walletID: Int)
    func addNewAccount(_ wallet: Wallet)
    func showAccountDetailsDialog(_ account: DcrlibwalletAccount)
}

class WalletInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var expandCollapseToggleImageView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var accountsTableViewHeightConstraint: NSLayoutConstraint!
    
    var delegate: WalletInfoTableViewCellDelegate?
    
    static let walletInfoSectionHeight: CGFloat = 65.0
    static let accountCellHeight: CGFloat = 74.0
    static let addNewAccountButtonHeight: CGFloat = 56
    
    var wallet: Wallet? {
        didSet {
            self.walletNameLabel.text = wallet?.name
            self.walletBalanceLabel.text = wallet?.balance
            
            self.accountsTableViewHeightConstraint.constant = self.accountsTableViewHeight
            self.accountsTableView.isHidden = self.numberOfAccountsToDisplay == 0
            
            if self.accountsTableView.delegate == nil {
                self.accountsTableView.dataSource = self
                self.accountsTableView.delegate = self
                self.accountsTableView.registerCellNib(WalletAccountTableViewCell.self)
            } else {
                self.accountsTableView.reloadData()
            }

            UIView.animate(withDuration: 0.1) {
                let rotationAngle = self.wallet?.displayAccounts ?? false ? CGFloat(Double.pi/2) : 0.0
                self.expandCollapseToggleImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }
        }
    }
    
    var numberOfAccountsToDisplay: Int {
        return self.wallet != nil && self.wallet!.displayAccounts ? self.wallet!.accounts.count : 0
    }
    
    var accountsTableViewHeight: CGFloat {
        return CGFloat(self.numberOfAccountsToDisplay) * WalletInfoTableViewCell.accountCellHeight
    }
    
    @IBAction func walletMenuButtonTapped(_ sender: Any) {
        guard let wallet = self.wallet else { return }
        self.delegate?.showWalletMenu(walletName: wallet.name, walletID: wallet.id)
    }
    
    @IBAction func addNewAccountTapped(_ sender: Any) {
        guard let wallet = self.wallet else { return }
        self.delegate?.addNewAccount(wallet)
    }
}

extension WalletInfoTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let borderView = UIView()
        borderView.backgroundColor = UIColor.appColors.gray
        return borderView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfAccountsToDisplay
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WalletInfoTableViewCell.accountCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletAccountTableViewCell") as! WalletAccountTableViewCell
        accountViewCell.account = self.wallet!.accounts[indexPath.row]
        return accountViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let wallet = self.wallet else { return }
        self.delegate?.showAccountDetailsDialog(wallet.accounts[indexPath.row])
    }
}
