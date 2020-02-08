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
    
    private var account: DcrlibwalletAccount!
    private var onAccountDetailsUpdated: (() -> ())?
    private var showAccountProperties = false
    
    static func showDetails(for account: DcrlibwalletAccount,
                            onAccountDetailsUpdated: (() -> ())?,
                            sender vc: UIViewController) {
        
        let accountDetailsView = AccountDetailsViewController.instantiate(from: .Wallets)
        accountDetailsView.account = account
        accountDetailsView.onAccountDetailsUpdated = onAccountDetailsUpdated
        
        accountDetailsView.modalPresentationStyle = .pageSheet
        vc.present(accountDetailsView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accountPropertiesSection.isHidden = true
        self.accountNameLabel.text = self.account.name
        self.displayAccountBalances()
        self.populateOtherAccountProperties()
        
        self.dismissViewOnTapAround()
    }
    
    func displayAccountBalances() {
        self.totalBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: self.account.dcrTotalBalance,
                                                                               smallerTextSize: 20)
        
        self.spendableBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: self.account.dcrTotalBalance,
                                                                                   smallerTextSize: 15)
        
        if let immatureReward = self.account.balance?.dcrImmatureReward, immatureReward > 0 {
            self.immatureRewardsBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: immatureReward,
                                                                                             smallerTextSize: 15)
        } else {
            self.immatureRewardsBalanceLabel.superview?.isHidden = true
        }
        
        if let lockedByTickets = self.account.balance?.dcrLockedByTickets, lockedByTickets > 0 {
            self.lockedByTicketsBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: lockedByTickets,
                                                                                             smallerTextSize: 15)
        } else {
            self.lockedByTicketsBalanceLabel.superview?.isHidden = true
        }
        
        if let votingAuthority = self.account.balance?.dcrVotingAuthority, votingAuthority > 0 {
            self.votingAuthorityBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: votingAuthority,
                                                                                             smallerTextSize: 15)
        } else {
            self.votingAuthorityBalanceLabel.superview?.isHidden = true
        }
        
        if let immatureStakeGen = self.account.balance?.dcrImmatureStakeGeneration, immatureStakeGen > 0 {
            self.immatureStakeGenBalanceLabel.attributedText = Utils.amountAsAttributedString(amount: immatureStakeGen,
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
                Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.accountRenamed)
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
