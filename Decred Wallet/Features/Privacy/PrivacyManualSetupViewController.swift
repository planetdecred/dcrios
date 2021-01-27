//
//  PrivacyManualSetupViewController.swift
//  Decred Wallet
//
// Copyright (c) 2021 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class PrivacyManualSetupViewController: UIViewController {
    
    var wallet: DcrlibwalletWallet!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func setupManualMixer(_ sender: Any) {
        
    }
    
    func showReminder(callback: @escaping (Bool) -> Void) {
        let message = LocalizedStrings.setupMixerInfo
        SimpleOkCancelDialog.show(sender: self,
                                  title: LocalizedStrings.setupMixerWithTwoAccounts,
                                  message: message,
                                  warningText: LocalizedStrings.setupMixerWithTwoAccounts,
                                  okButtonText: LocalizedStrings.beginSetup,
                                  callback: callback)
    }
    
    func AuthMixerAccount() {
        self.showReminder { ok in
            guard ok else { return }
            Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: self.wallet.id_))
                .with(prompt: LocalizedStrings.confirmToCreateMixer)
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
    
}
