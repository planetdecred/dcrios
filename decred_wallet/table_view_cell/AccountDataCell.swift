//  AccountDataCell.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

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
    private var accountNumber: Int32  = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func setDefault(_ sender: Any) {
        UserDefaults.standard.set(self.accountNumber, forKey: "wallet_default")
        print("set default")
        print(self.accountNumber)
    }
   
    func setup(account: AccountsEntity) {
        labelImmatureRewardValue.text = "\(account.Balance?.dcrImmatureReward ?? 0)"
        labelLockedByTicketsValue.text = "\(account.Balance?.dcrLockedByTickets ?? 0)"
        labelVotingAuthorityValue.text = "\(account.Balance?.dcrVotingAuthority ?? 0)"
        labelImmatureStakeGenerationValue.text = "\(account.Balance?.dcrImmatureStakeGeneration ?? 0)"
        labelAccountNoValue.text = "\(account.Number)"
        //labelHDPathValue.text = "\(account.Balance)"
        labelKeysValue.text = "\(account.ExternalKeyCount) External, \(account.InternalKeyCount) Internal, \(account.ImportedKeyCount) Imported"
        self.accountNumber = account.Number
        if( UserDefaults.standard.integer(forKey: "wallet_default") == account.Number){
            print("set on")
            defaultAccount.setOn(true, animated: true)
        }
        else{
            defaultAccount.setOn(false, animated: true)
        }
        
    }
}
