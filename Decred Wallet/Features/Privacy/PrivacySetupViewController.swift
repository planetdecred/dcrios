//
//  PrivacySetupViewController.swift
//  Decred Wallet
//
//  Created by Suleiman Abubakar on 29/12/2020.
//  Copyright © 2020 Decred. All rights reserved.
//

import UIKit
import Dcrlibwallet

class PrivacySetupViewController: UIViewController {
    @IBOutlet weak var setupMixerBtn: Button!
    var wallet: DcrlibwalletWallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func setupMixer(_ sender: Any) {
        self.showReminder { ok in
            guard ok else { return }
            
            Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: self.wallet.id_))
                .with(prompt: "Confirm to create needed accounts")
                .with(submitBtnText: LocalizedStrings.remove)
                .requestCurrentCode(sender: self) { spendingCode, _, dialogDelegate in
                
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                          //  try WalletLoader.shared.multiWallet.startAccountMixer(self.wallet.id_, walletPassphrase: spendingCode)
                            DispatchQueue.main.async {
                                dialogDelegate?.dismissDialog()
                                
                            }
                        } catch let error {
                            DispatchQueue.main.async {
                                var errorMessage = error.localizedDescription
                                if error.isInvalidPassphraseError {
                                    errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.wallet.id_)
                                }
                                dialogDelegate?.displayError(errorMessage: errorMessage)
                            }
                        }
                    }
            }
            
        }
    }
    
    func showReminder(callback: @escaping (Bool) -> Void) {
        let message = "Two dedicated accounts (“mixed” & “unmixed”) will be created in order to use the mixer."
        SimpleOkCancelDialog.show(sender: self,
                                  title: "Set up mixer by creating two needed accounts",
                                  message: message,
                                  warningText: "Set up mixer by creating two needed accounts",
                                  okButtonText: "Begin setup",
                                  callback: callback)
    }

}
