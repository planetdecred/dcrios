//  AccountDataCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class AccountDataCell: UITableViewCell, AccountDetailsCellProtocol {
    
    @IBOutlet private weak var containerStackView: UIStackView!
    
    // MARK:- Details
    @IBOutlet weak var detailsStackView: UIStackView!
    @IBOutlet private weak var labelImmatureRewardValue: UILabel!
    @IBOutlet private weak var labelLockedByTicketsValue: UILabel!
    @IBOutlet private weak var labelVotingAuthorityValue: UILabel!
    @IBOutlet private weak var labelImmatureStakeGenerationValue: UILabel!
    
    // MARK:- Properties
    @IBOutlet private weak var labelAccountNoValue: UILabel!
    @IBOutlet private weak var labelHDPathValue: UILabel!
    @IBOutlet private weak var labelKeysValue: UILabel!
    @IBOutlet weak var defaultAccount: UISwitch!
    private var accountTmp: WalletAccount!
    @IBOutlet weak var hideAcount: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func setHiddenAccount(_ sender: Any) {
        Settings.setValue(hideAcount.isOn, for: "\(Settings.Keys.HiddenWallet)\(accountTmp.Number)")
    }
    
    @IBAction func setDefault(_ sender: Any) {
        self.accountTmp.makeDefault()
        self.hideAcount.setOn(false, animated: true)
        self.hideAcount.isEnabled = false
        Settings.setValue(false, for: "\(Settings.Keys.HiddenWallet)\(accountTmp.Number)")
    }
    
    func setup(account: WalletAccount) {
        self.accountTmp = account
        
        labelImmatureRewardValue.text = "\(account.Balance?.dcrImmatureReward ?? 0)"
        labelLockedByTicketsValue.text = "\(account.Balance?.dcrLockedByTickets ?? 0)"
        labelVotingAuthorityValue.text = "\(account.Balance?.dcrVotingAuthority ?? 0)"
        labelImmatureStakeGenerationValue.text = "\(account.Balance?.dcrImmatureStakeGeneration ?? 0)"
        labelAccountNoValue.text = "\(account.Number)"
        labelKeysValue.text = "\(account.ExternalKeyCount) External, \(account.InternalKeyCount) Internal, \(account.ImportedKeyCount) Imported"
        
        if BuildConfig.IsTestNet {
            labelHDPathValue.text = "\(GlobalConstants.Strings.TESTNET_HD_PATH) \(account.Number)'"
        }else {
            labelHDPathValue.text = "\(GlobalConstants.Strings.MAINNET_HD_PATH) \(account.Number)'"
        }
        
        if account.Number == INT_MAX {
            defaultAccount.setOn(false, animated: false)
            defaultAccount.isEnabled = false
            hideAcount.setOn(false, animated: false)
            hideAcount.isEnabled = false
        }else {
            let hidden = UserDefaults.standard.bool(forKey: "\(Settings.Keys.HiddenWallet)\(self.accountTmp.Number)")
            if (hidden){
                hideAcount.setOn(true, animated: false)
                hideAcount.isEnabled = true
            }else {
                hideAcount.setOn(false, animated: false)
                hideAcount.isEnabled = true
            }
            if (account.isDefault){
                defaultAccount.setOn(true, animated: false)
                defaultAccount.isEnabled = false
                hideAcount.setOn(false, animated: false)
                hideAcount.isEnabled = false
            }else {
                defaultAccount.setOn(false, animated: false)
                defaultAccount.isEnabled = true
                hideAcount.isEnabled = true
            }
        }
        
        if account.Balance?.ImmatureReward == 0 && account.Balance?.LockedByTickets == 0 &&
            account.Balance?.VotingAuthority == 0 && account.Balance?.ImmatureStakeGeneration == 0{
            detailsStackView.isHidden = true
        }
        
    }
}
