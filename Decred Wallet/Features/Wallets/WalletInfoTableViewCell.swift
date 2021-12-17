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
    func showWalletMenu(walletName: String, walletID: Int, type: DropDowMenuEnum?)
    func addNewAccount(_ wallet: Wallet)
    func showAccountDetailsDialog(_ account: DcrlibwalletAccount)
    func gotoPrivacy(_ wallet: Wallet)
    func indexDropdownOpen(index: IndexPath)
    func gotoSeedBackup(vc: UIViewController)
}

class WalletInfoTableViewCell: UITableViewCell, DropMenuButtonDelegate {
    
    @IBOutlet weak var expandCollapseToggleImageView: UIImageView!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var walletNotBackedUpLabel: UILabel!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    
    @IBOutlet weak var accountsSection: UIView!
    @IBOutlet weak var accountsTableView: UITableView!
    @IBOutlet weak var accountsTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var privacyTootipView: TooltipView!
    @IBOutlet weak var seedBackupPrompt: UIView! {
        didSet {
            self.seedBackupPrompt.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.seedBackupPromptTapped))
            )
        }
    }
    @IBOutlet weak var walletMenuButton: DropMenuButton!
    
    @IBOutlet weak var checkMixerStatusView: UIView!
    @IBOutlet weak var checkMixerStatusDivider: UIView!
    
    var delegate: WalletInfoTableViewCellDelegate?
    var indexPath: IndexPath!
    
    static let walletInfoSectionHeight: CGFloat = 65.0
    static let walletNotBackedUpLabelHeight: CGFloat = 14.0
    static let accountCellHeight: CGFloat = 74.0
    static let addNewAccountButtonHeight: CGFloat = 56
    static let seedBackupPromptHeight: CGFloat = 92.0
    static let checkMixerStatusHeight:CGFloat = 34.0
    private var menuOption: [DropMenuButtonItem] = []
    
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
            
            if wallet.isSeedBackedUp {
                self.walletNotBackedUpLabel.isHidden = true
                self.seedBackupPrompt.isHidden = true
            } else {
                self.walletNotBackedUpLabel.isHidden = false
                self.walletNotBackedUpLabel.text = LocalizedStrings.notBackedUp
                self.walletNotBackedUpLabel.textColor = UIColor.appColors.orange
                self.seedBackupPrompt.isHidden = false
            }
            
            if wallet.isAccountMixerActive {
                self.walletNotBackedUpLabel.isHidden = false
                self.walletNotBackedUpLabel.textColor = UIColor.appColors.text4
                self.walletNotBackedUpLabel.text = LocalizedStrings.mixing
                self.showCheckMixerStatusView()
            } else {
                self.hideCheckMixerStatusView()
            }
            
            let multiWallet = WalletLoader.shared.multiWallet!
            if !multiWallet.readBoolConfigValue(forKey: GlobalConstants.Strings.SHOWN_PRIVACY_TOOLTIP, defaultValue: false) {
                self.showToolTip()
                multiWallet.setBoolConfigValueForKey(GlobalConstants.Strings.SHOWN_PRIVACY_TOOLTIP, value: true)
            }

            UIView.animate(withDuration: 0.1) {
                let rotationAngle = self.wallet.displayAccounts ? CGFloat(Double.pi/2) : 0.0
                self.expandCollapseToggleImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }
        }
    }
    
    func setupMenuDropDown(indexPath: IndexPath) {
        self.indexPath = indexPath
        self.menuOption = [
            DropMenuButtonItem(LocalizedStrings.signMessage, isSeparate: false, textLabel: ""),
            DropMenuButtonItem(LocalizedStrings.verifyMessage, isSeparate: false, textLabel: ""),
            DropMenuButtonItem(LocalizedStrings.privacy, isSeparate: true, textLabel: "New"),
            DropMenuButtonItem(LocalizedStrings.rename, isSeparate: true, textLabel: ""),
            DropMenuButtonItem(LocalizedStrings.settings, isSeparate: false, textLabel: ""),
        ]
        if WalletLoader.shared.multiWallet.readBoolConfigValue(forKey: GlobalConstants.Strings.HAS_SETUP_PRIVACY, defaultValue: false) {
            self.menuOption[2] = DropMenuButtonItem(LocalizedStrings.privacy, isSeparate: true, textLabel: "")
        }
        
        self.walletMenuButton.delegate = self
        
        self.walletMenuButton.initMenu(self.menuOption, align: .right, marginHorizontal: 16, isDissmissOutside: true, superView: self.superview?.superview, isShowCurrentValue: true) { [weak self] index, value in
            guard let `self` = self else {return}
            self.delegate?.showWalletMenu(walletName: self.wallet.name, walletID: self.wallet.id, type: DropDowMenuEnum(rawValue: index))
        }
    }
    
    func hideCheckMixerStatusView() {
        self.checkMixerStatusView.isHidden = true
        self.checkMixerStatusDivider.isHidden = true
    }
    
    func showCheckMixerStatusView() {
        self.checkMixerStatusView.isHidden = false
        self.checkMixerStatusDivider.isHidden = wallet.displayAccounts ? true : false
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
        self.delegate?.gotoSeedBackup(vc: seedBackupReminderVC)
    }
    
    @IBAction func checkMixerStatus(_ sender: Any) {
        self.delegate?.gotoPrivacy(self.wallet)
    }
    
    @IBAction func addNewAccountTapped(_ sender: Any) {
        self.delegate?.addNewAccount(self.wallet)
    }
    
    func showToolTip() {
        self.privacyTootipView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.privacyTootipView.isHidden = true
        }
    }
    
    func closeDropDown() {
        self.walletMenuButton.hideDropDown()
    }
    
    func onOpenDrop() {
        self.delegate?.indexDropdownOpen(index: self.indexPath)
    }
}

extension WalletInfoTableViewCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfAccountsToDisplay
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WalletInfoTableViewCell.accountCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountViewCell = tableView.dequeueReusableCell(withIdentifier: "WalletAccountTableViewCell") as! WalletAccountTableViewCell
        accountViewCell.account = self.wallet.accounts[indexPath.row]
        if indexPath.row == 0 {
            accountViewCell.separator.isHidden = true
        }
        return accountViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.showAccountDetailsDialog(self.wallet.accounts[indexPath.row])
    }
}
