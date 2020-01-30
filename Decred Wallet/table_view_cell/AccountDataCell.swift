//  AccountDataCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

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
    private var accountTmp: DcrlibwalletAccount!
    @IBOutlet weak var hideAcount: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func setHiddenAccount(_ sender: Any) {
        // deprecated
    }
    
    @IBAction func setDefault(_ sender: Any) {
        self.accountTmp.makeDefault()
        self.hideAcount.setOn(false, animated: true)
        self.hideAcount.isEnabled = false
        // deprecated
    }
    
    func setup(account: DcrlibwalletAccount) {
        self.accountTmp = account
        
        labelImmatureRewardValue.text = "\(account.balance?.dcrImmatureReward ?? 0)"
        labelLockedByTicketsValue.text = "\(account.balance?.dcrLockedByTickets ?? 0)"
        labelVotingAuthorityValue.text = "\(account.balance?.dcrVotingAuthority ?? 0)"
        labelImmatureStakeGenerationValue.text = "\(account.balance?.dcrImmatureStakeGeneration ?? 0)"
        labelAccountNoValue.text = "\(account.number)"
        labelKeysValue.text = "\(account.externalKeyCount) \(LocalizedStrings.external), \(account.internalKeyCount) \(LocalizedStrings.internal), \(account.importedKeyCount) \(LocalizedStrings.imported)"
        
        if BuildConfig.IsTestNet {
            labelHDPathValue.text = "\(GlobalConstants.Strings.TESTNET_HD_PATH) \(account.number)'"
        } else {
            labelHDPathValue.text = "\(GlobalConstants.Strings.MAINNET_HD_PATH) \(account.number)'"
        }
        
        if account.number == INT_MAX {
            defaultAccount.setOn(false, animated: false)
            defaultAccount.isEnabled = false
            hideAcount.setOn(false, animated: false)
            hideAcount.isEnabled = false
        } else {
            if account.isHidden {
                hideAcount.setOn(true, animated: false)
                hideAcount.isEnabled = true
            } else {
                hideAcount.setOn(false, animated: false)
                hideAcount.isEnabled = true
            }
            if account.isDefault {
                defaultAccount.setOn(true, animated: false)
                defaultAccount.isEnabled = false
                hideAcount.setOn(false, animated: false)
                hideAcount.isEnabled = false
            } else {
                defaultAccount.setOn(false, animated: false)
                defaultAccount.isEnabled = true
                hideAcount.isEnabled = true
            }
        }
        
        if account.balance?.immatureReward == 0 && account.balance?.lockedByTickets == 0 &&
            account.balance?.votingAuthority == 0 && account.balance?.immatureStakeGeneration == 0 {
            detailsStackView.isHidden = true
        }
        
    }
}
