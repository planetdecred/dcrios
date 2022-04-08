//
//  PrivacySetupTypeViewController.swift
//  Decred Wallet
//
// Copyright (c) 2021 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class PrivacySetupTypeViewController: UIViewController {
    @IBOutlet weak var autoSetupView: RoundedView!
    @IBOutlet weak var manualSetupView: RoundedView!
    
    @IBOutlet weak var walletName: UILabel!
    var wallet: DcrlibwalletWallet!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.autoSetupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkAccountNameConflict)))
        self.manualSetupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setupManuelMixer)))
        
        self.walletName.text = wallet.name
    }
    
    @objc func setupManuelMixer() {
        guard let wallet = WalletLoader.shared.multiWallet.wallet(withID: wallet.id_) else {
            return
        }
        
        let PrivacyManualSetupVC = PrivacyManualSetupViewController.instantiate(from: .Privacy)
        PrivacyManualSetupVC.wallet = wallet
        self.navigationController?.pushViewController(PrivacyManualSetupVC, animated: true)
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismissView()
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
    
    @objc func checkAccountNameConflict() {
        if wallet.hasAccount(GlobalConstants.Strings.MIXED) || wallet.hasAccount(GlobalConstants.Strings.UNMIXED) {
            SimpleAlertDialog.show(sender: self, title: LocalizedStrings.accountNameTaken, message: LocalizedStrings.accountNameTakenMsg, okButtonText: LocalizedStrings.goBackAndRename, hideAlertIcon: false) { ok in
                    self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        self.AuthMixerAccount()
    }
    
    func AuthMixerAccount() {
        self.showReminder { ok in
            guard ok else { return }
            if LocalAuthentication.isWalletSetupBiometric(walletId: self.wallet.id_) {
                LocalAuthentication.localAuthenticaionWithWallet(walletId: self.wallet.id_, completed: { result, error in
                    if let passOrPin = result {
                        DispatchQueue.global(qos: .userInitiated).async {
                            do {
                                try self.wallet.createMixerAccounts(GlobalConstants.Strings.MIXED, unmixedAccount: GlobalConstants.Strings.UNMIXED, privPass: passOrPin)
                                WalletLoader.shared.multiWallet.setBoolConfigValueForKey("has_setup_privacy", value: true)
                                
                                DispatchQueue.main.async {
                                    Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.mixerSetupCompleted)
                                    let PrivacyViewVC = PrivacyViewController.instantiate(from: .Privacy)
                                    PrivacyViewVC.wallet = self.wallet
                                    self.navigationController?.pushViewController(PrivacyViewVC, animated: true)
                                    
                                }
                            } catch let error {
                                print("sign error:", error.localizedDescription)
                                Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
                            }
                        }
                    } else {
                        self.autoSetupByPinPass()
                    }
                })
            } else {
                self.autoSetupByPinPass()
            }
        }
    }
    
    func autoSetupByPinPass() {
        Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: self.wallet.id_))
            .with(prompt: LocalizedStrings.confirmToCreateMixer)
            .with(submitBtnText: LocalizedStrings.confirm)
            .requestCurrentCode(sender: self) { spendingCode, _, dialogDelegate in
            
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try self.wallet.createMixerAccounts(GlobalConstants.Strings.MIXED, unmixedAccount: GlobalConstants.Strings.UNMIXED, privPass: spendingCode)
                        WalletLoader.shared.multiWallet.setBoolConfigValueForKey("has_setup_privacy", value: true)
                        
                        DispatchQueue.main.async {
                            dialogDelegate?.dismissDialog()
                            
                            Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.mixerSetupCompleted)
                            
                            let PrivacyViewVC = PrivacyViewController.instantiate(from: .Privacy)
                            PrivacyViewVC.wallet = self.wallet
                            self.navigationController?.pushViewController(PrivacyViewVC, animated: true)
                            
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            var errorMessage = error.localizedDescription
                            if error.isInvalidPassphraseError {
                                errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.wallet.id_)
                            }
                            Utils.showBanner(in: self.view, type: .error, text: errorMessage)
                            dialogDelegate?.displayError(errorMessage: errorMessage)
                        }
                    }
                }
        }
    }

}
