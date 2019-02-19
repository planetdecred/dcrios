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
    @IBOutlet private weak var labelImmatureRewardValue: UILabel!
    @IBOutlet private weak var labelLockedByTicketsValue: UILabel!
    @IBOutlet private weak var labelVotingAuthorityValue: UILabel!
    @IBOutlet private weak var labelImmatureStakeGenerationValue: UILabel!
    
    // MARK:- Properties
    @IBOutlet private weak var labelAccountNoValue: UILabel!
    @IBOutlet private weak var labelHDPathValue: UILabel!
    @IBOutlet private weak var labelKeysValue: UILabel!
    @IBOutlet weak var defaultAccount: UISwitch!
    private var accountTmp: AccountsEntity!
    @IBOutlet weak var hideAcount: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func setHiddenAccount(_ sender: Any) {
        UserDefaults.standard.set(hideAcount.isOn, forKey: "hidden\(accountTmp.Number)")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func setDefault(_ sender: Any) {
        self.accountTmp.makeDefault()
        self.hideAcount.setOn(false, animated: true)
        self.hideAcount.isEnabled = false
        UserDefaults.standard.set(false, forKey: "hidden\(accountTmp.Number)")
        UserDefaults.standard.synchronize()
    }
    
    func setup(account: AccountsEntity) {
        self.accountTmp = account
        
        labelImmatureRewardValue.text = "\(account.Balance?.dcrImmatureReward ?? 0)"
        labelLockedByTicketsValue.text = "\(account.Balance?.dcrLockedByTickets ?? 0)"
        labelVotingAuthorityValue.text = "\(account.Balance?.dcrVotingAuthority ?? 0)"
        labelImmatureStakeGenerationValue.text = "\(account.Balance?.dcrImmatureStakeGeneration ?? 0)"
        labelAccountNoValue.text = "\(account.Number)"
        labelKeysValue.text = "\(account.ExternalKeyCount) External, \(account.InternalKeyCount) Internal, \(account.ImportedKeyCount) Imported"
        
        if (account.Number == INT_MAX) {
            defaultAccount.setOn(false, animated: false)
            defaultAccount.isEnabled = false
            hideAcount.setOn(false, animated: false)
            hideAcount.isEnabled = false
        }else{
            let hidden = UserDefaults.standard.bool(forKey: "hidden\(account.Number)")
            if (hidden){
                hideAcount.setOn(true, animated: false)
                hideAcount.isEnabled = true
            }
            else{
                hideAcount.setOn(false, animated: false)
                hideAcount.isEnabled = true
            }
            if (account.isDefaultWallet){
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
        
        
        
        
    }
}
