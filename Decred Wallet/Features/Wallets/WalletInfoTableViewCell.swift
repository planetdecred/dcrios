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
    func walletSeedBackedUp()
    func showWalletMenu(walletName: String, walletID: Int, _ sender: UIView)
    func addNewAccount(_ wallet: Wallet)
    func showAccountDetailsDialog(_ account: DcrlibwalletAccount)
}

class WalletInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var expandCollapseToggleImageView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletNotBackedUpLabel: UILabel!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    
    @IBOutlet weak var accountsSection: UIView!
    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var accountsTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var seedBackupPrompt: UIView! {
        didSet {
            self.seedBackupPrompt.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.seedBackupPromptTapped))
            )
        }
    }
    
    var delegate: WalletInfoTableViewCellDelegate?
    
    static let walletInfoSectionHeight: CGFloat = 65.0
    static let walletNotBackedUpLabelHeight: CGFloat = 14.0
    static let accountCellHeight: CGFloat = 74.0
    static let addNewAccountButtonHeight: CGFloat = 56
    static let seedBackupPromptHeight: CGFloat = 92.0
    
    var wallet: Wallet! {
        didSet {
            self.walletNameLabel.text = wallet.name
            self.walletBalanceLabel.text = wallet.balance
            
            self.accountsSection.isHidden = !wallet.displayAccounts
            self.accountsTableViewHeightConstraint.constant = self.accountsTableViewHeight
            
            if self.accountsTableView.delegate == nil {
                self.accountsTableView.dataSource = self
                self.accountsTableView.delegate = self
                self.accountsTableView.registerCellNib(WalletAccountTableViewCell.self)
            } else {
                self.accountsTableView.reloadData()
            }
            
            self.walletNotBackedUpLabel.isHidden = wallet.isSeedBackedUp
            self.seedBackupPrompt.isHidden = wallet.isSeedBackedUp

            UIView.animate(withDuration: 0.1) {
                let rotationAngle = self.wallet.displayAccounts ? CGFloat(Double.pi/2) : 0.0
                self.expandCollapseToggleImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }
        }
    }
    
    var numberOfAccountsToDisplay: Int {
        return self.wallet != nil && self.wallet.displayAccounts ? self.wallet.accounts.count : 0
    }
    
    var accountsTableViewHeight: CGFloat {
        return CGFloat(self.numberOfAccountsToDisplay) * WalletInfoTableViewCell.accountCellHeight
    }
    
    @objc func seedBackupPromptTapped(_ sender: Any) {
        let seedBackupReminderVC = SeedBackupReminderViewController.instantiate(from: .SeedBackup)
        seedBackupReminderVC.walletID = self.wallet.id
        seedBackupReminderVC.seedBackupCompleted = {
            self.delegate?.walletSeedBackedUp()
        }
        
        let modalVC = seedBackupReminderVC.wrapInNavigationcontroller()
        modalVC.modalPresentationStyle = .overFullScreen
        AppDelegate.shared.window?.rootViewController?.present(modalVC, animated: true)
    }
    
    @IBAction func walletMenuButtonTapped(_ sender: UIView) {
        self.delegate?.showWalletMenu(walletName: self.wallet.name, walletID: self.wallet.id, sender)
    }
    
    @IBAction func addNewAccountTapped(_ sender: Any) {
        self.delegate?.addNewAccount(self.wallet)
    }
}

extension WalletInfoTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfAccountsToDisplay
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WalletInfoTableViewCell.accountCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletAccountTableViewCell") as! WalletAccountTableViewCell
        accountViewCell.account = self.wallet.accounts[indexPath.row]
        return accountViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.showAccountDetailsDialog(self.wallet.accounts[indexPath.row])
    }
}
