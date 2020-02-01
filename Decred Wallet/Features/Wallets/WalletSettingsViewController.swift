//
//  WalletSettingsViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class WalletSettingsViewController: UIViewController {
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var useFingerprintSwitch: UISwitch!
    @IBOutlet weak var incomingTxAlertButton: UIButton!
    
    var wallet: DcrlibwalletWallet!
    var walletSettings: WalletSettings!
    
    override func viewWillAppear(_ animated: Bool) {
        self.walletNameLabel.text = self.wallet.name
        self.walletSettings = WalletSettings(for: self.wallet)
        
        self.useFingerprintSwitch.isOn = self.walletSettings.useFingerprint
        self.incomingTxAlertButton.setTitle(self.walletSettings.txNotificationAlert.localizedString, for: .normal)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func useFingerprintSwitchToggle(_ sender: Any) {
        self.walletSettings.setBoolValue(self.useFingerprintSwitch.isOn, for: DcrlibwalletUseFingerprintConfigKey)
    }
    
    @IBAction func changeSpendingPINPassword(_ sender: Any) {
        SpendingPinOrPassword.change(sender: self, walletID: self.wallet.id_) {
            Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.spendingPinPassChanged)
        }
    }
    
    @IBAction func changeIncomingTransactionsNotificationsSetting(_ sender: Any) {
    }
    
    @IBAction func removeWalletFromDevice(_ sender: Any) {
        self.showRemoveWalletWarning() { ok in
            guard ok else { return }
            
            Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: self.wallet.id_))
                .with(prompt: LocalizedStrings.confirmToRemove)
                .with(submitBtnText: LocalizedStrings.remove)
                .requestCurrentCode(sender: self) { spendingCode, _, dialogDelegate in
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try WalletLoader.shared.multiWallet.delete(self.wallet.id_, privPass: spendingCode.utf8Bits)
                            DispatchQueue.main.async {
                                dialogDelegate?.dismissDialog()
                                Utils.showBanner(parentVC: self, type: .success, text: LocalizedStrings.walletRemoved)
                                
                                // todo clear wallet settings
                                self.restartAppIfLastWalletDeleted()
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
    
    func showRemoveWalletWarning(callback: @escaping (Bool) -> Void) {
        SimpleOkCancelDialog.show(sender: self,
                                  title: LocalizedStrings.removeWalletConfirmation,
                                  message: LocalizedStrings.removeWalletWarning,
                                  callback: self.removeWalletFromDevice)
    }
    
    func restartAppIfLastWalletDeleted() {
        if WalletLoader.shared.multiWallet.openedWalletsCount() == 0 {
            Settings.clear()
            let startScreen = Storyboard.Main.initialViewController()
            AppDelegate.shared.setAndDisplayRootViewController(startScreen!)
        }
    }
}
