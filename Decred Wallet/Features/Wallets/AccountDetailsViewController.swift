//
//  AccountDetailsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class AccountDetailsViewController: UIViewController {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var spendableBalanceLabel: UILabel!
    @IBOutlet weak var immatureRewardsBalanceLabel: UILabel!
    @IBOutlet weak var lockedByTicketsBalanceLabel: UILabel!
    @IBOutlet weak var votingAuthorityBalanceLabel: UILabel!
    @IBOutlet weak var immatureStakeGenBalanceLabel: UILabel!
    
    @IBOutlet weak var accountPropertiesSection: UIView!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountHDPathLabel: UILabel!
    @IBOutlet weak var accountKeysLabel: UILabel!
    
    @IBOutlet weak var accountPropertiesContainerConst: NSLayoutConstraint!
    @IBOutlet weak var accountNumberContraint: NSLayoutConstraint!
    @IBOutlet weak var accountNumerLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var hdPathConstraint: NSLayoutConstraint!
    @IBOutlet weak var hdPathLabelContaint: NSLayoutConstraint!
    @IBOutlet weak var HdPathTopSpace: NSLayoutConstraint!
    @IBOutlet weak var accountNumberTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var renameAccountBtn: UIButton!
    
    private var wallet: Wallet!
    private var account: DcrlibwalletAccount!
    private var isWatchOnlyWallet = false
    private var onAccountDetailsUpdated: (() -> ())?
    private var showAccountProperties = false
    
    static func showDetails(for account: DcrlibwalletAccount,
                            onAccountDetailsUpdated: (() -> ())?,
                            sender vc: UIViewController) {
        
        let accountDetailsView = AccountDetailsViewController.instantiate(from: .Wallets)
        accountDetailsView.account = account
        accountDetailsView.isWatchOnlyWallet = false
        accountDetailsView.onAccountDetailsUpdated = onAccountDetailsUpdated
        
        accountDetailsView.modalPresentationStyle = .pageSheet
        DispatchQueue.main.async {
            vc.present(accountDetailsView, animated: true, completion: nil)
        }
        
    }
    
    static func showWatchOnlyWalletDetails(for wallet: Wallet,
                            onAccountDetailsUpdated: (() -> ())?,
                            sender vc: UIViewController) {
        
        let accountDetailsView = AccountDetailsViewController.instantiate(from: .Wallets)
        accountDetailsView.wallet = wallet
        accountDetailsView.account = wallet.accounts.first
        accountDetailsView.isWatchOnlyWallet = true
        accountDetailsView.onAccountDetailsUpdated = onAccountDetailsUpdated
        
        accountDetailsView.modalPresentationStyle = .pageSheet
        DispatchQueue.main.async {
            vc.present(accountDetailsView, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accountPropertiesSection.isHidden = true
        self.accountNameLabel.text = self.isWatchOnlyWallet ? self.wallet.name : self.account.name
        self.renameAccountBtn.isHidden = self.isWatchOnlyWallet ? true : false
        self.setupAccountProperties()
        
        self.displayAccountBalances()
        self.populateOtherAccountProperties()
        
        self.dismissViewOnTapAround()
        
        // register for new transactions notifications
        try? WalletLoader.shared.multiWallet.add(self, async: true, uniqueIdentifier: "\(self)")
    }
    
    func setupAccountProperties() {
        self.accountPropertiesContainerConst.constant = self.isWatchOnlyWallet ? 85 : 153
        
        self.accountNumberContraint.constant = self.isWatchOnlyWallet ? 0 : 18
        self.accountNumerLabelConstraint.constant = self.isWatchOnlyWallet ? 0 : 18
        self.hdPathConstraint.constant = self.isWatchOnlyWallet ? 0 : 18
        self.hdPathLabelContaint.constant = self.isWatchOnlyWallet ? 0 : 18
        
        self.accountNumberTopSpace.constant = self.isWatchOnlyWallet ? 0 : 16
        self.HdPathTopSpace.constant = self.isWatchOnlyWallet ? 0 : 16
    }
    
    func displayAccountBalances() {
        self.totalBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: self.account.balance?.dcrTotal,
                                                                               smallerTextSize: 20)
        
        self.spendableBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: self.account.dcrSpendableBalance,
                                                                                   smallerTextSize: 15)
        
        if let immatureReward = self.account.balance?.dcrImmatureReward, immatureReward > 0 {
            self.immatureRewardsBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: immatureReward,
                                                                                             smallerTextSize: 15)
        } else {
            self.immatureRewardsBalanceLabel.superview?.isHidden = true
        }
        
        if let lockedByTickets = self.account.balance?.dcrLockedByTickets, lockedByTickets > 0 {
            self.lockedByTicketsBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: lockedByTickets,
                                                                                             smallerTextSize: 15)
        } else {
            self.lockedByTicketsBalanceLabel.superview?.isHidden = true
        }
        
        if let votingAuthority = self.account.balance?.dcrVotingAuthority, votingAuthority > 0 {
            self.votingAuthorityBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: votingAuthority,
                                                                                             smallerTextSize: 15)
        } else {
            self.votingAuthorityBalanceLabel.superview?.isHidden = true
        }
        
        if let immatureStakeGen = self.account.balance?.dcrImmatureStakeGeneration, immatureStakeGen > 0 {
            self.immatureStakeGenBalanceLabel.attributedText = Utils.amountShowedInEightDecimals(amount: immatureStakeGen,
                                                                                              smallerTextSize: 15)
        } else {
            self.immatureStakeGenBalanceLabel.superview?.isHidden = true
        }
    }
    
    func populateOtherAccountProperties() {
        self.accountNumberLabel.text = "\(self.account.number)"
        
        if BuildConfig.IsTestNet {
            self.accountHDPathLabel.text = "\(GlobalConstants.Strings.TESTNET_HD_PATH) \(account.number)'"
        } else {
            self.accountHDPathLabel.text = "\(GlobalConstants.Strings.MAINNET_HD_PATH) \(account.number)'"
        }
        
        self.accountKeysLabel.text = "\(account.externalKeyCount) \(LocalizedStrings.external), \(account.internalKeyCount) \(LocalizedStrings.internal), \(account.importedKeyCount) \(LocalizedStrings.imported)"
    }
    
    @IBAction func editAccountNameTapped(_ sender: Any) {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: self.account.walletID) else {
            print("cannot rename account, invalid wallet id", self.account.walletID)
            self.dismissView()
            return
        }
        
        SimpleTextInputDialog.show(sender: self,
                                   title: LocalizedStrings.renameAccount,
                                   placeholder: LocalizedStrings.accountName,
                                   submitButtonText: LocalizedStrings.rename) { newAccountName, dialogDelegate in
            
            do {
                try wallet.renameAccount(self.account.number, newName: newAccountName)
                dialogDelegate?.dismissDialog()
                self.onAccountDetailsUpdated?()
                self.accountNameLabel.text = newAccountName
                Utils.showBanner(in: self.view.subviews.first!, type: .success, text: LocalizedStrings.accountRenamed)
            } catch let error {
                dialogDelegate?.displayError(errorMessage: error.localizedDescription)
            }
        }
    }
    
    @IBAction func toggleAccountPropertiesDisplay(_ sender: Any) {
        self.showAccountProperties.toggle()
        self.accountPropertiesSection.isHidden = !self.showAccountProperties
        
        let toggleButtonText = self.showAccountProperties ? LocalizedStrings.hideProperties : LocalizedStrings.showProperties
        (sender as! UIButton).setTitle(toggleButtonText, for: .normal)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissView()
    }
}

extension AccountDetailsViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
    }
    
    func onTransaction(_ transaction: String?) {
        let walletID = self.account.walletID
        let accountNumber = self.account.number
        do {
            self.account = try WalletLoader.shared.multiWallet.wallet(withID: walletID)?.getAccount(accountNumber)
            DispatchQueue.main.async {
                self.displayAccountBalances()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {
    }
}
