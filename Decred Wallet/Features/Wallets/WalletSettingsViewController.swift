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
    @IBOutlet weak var useBiometricSwitch: UISwitch!
    @IBOutlet weak var incomingTxAlertButton: UIButton!
    @IBOutlet weak var securityHeader: UIView!
    @IBOutlet weak var changePassOrPIN: UIView!
    
    var wallet: DcrlibwalletWallet!
    var walletSettings: WalletSettings!
    
    override func viewWillAppear(_ animated: Bool) {
        self.walletNameLabel.text = self.wallet.name
        self.walletSettings = WalletSettings(for: self.wallet)
        
        self.useBiometricSwitch.isOn = self.walletSettings.useBiometric
        self.incomingTxAlertButton.setTitle(self.walletSettings.txNotificationAlert.localizedString, for: .normal)
    }
    
    override func viewDidLoad() {
        self.securityHeader.isHidden = self.wallet.isWatchingOnlyWallet()
        self.changePassOrPIN.isHidden = self.wallet.isWatchingOnlyWallet()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismissView()
    }
    
    @IBAction func useBiometricSwitchToggle(_ sender: Any) {
        self.walletSettings.setBoolValue(self.useBiometricSwitch.isOn, for: "\(self.wallet.id_)" + DcrlibwalletUseBiometricConfigKey)
    }
    
    @IBAction func changeSpendingPINPassword(_ sender: Any) {
        SpendingPinOrPassword.change(sender: self, walletID: self.wallet.id_) {
            Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.spendingPinPassChanged)
        }
    }
    
    @IBAction func changeIncomingTransactionsNotificationsSetting(_ sender: Any) {
        let notificationAlertOptions = NotificationAlert.allCases.map({ $0.localizedString })
        let currentOption = self.walletSettings.txNotificationAlert.localizedString
        
        CheckableListDialogViewController.show(sender: self,
                                               title: LocalizedStrings.incomingTransactions,
                                               options: notificationAlertOptions,
                                               selectedOption: currentOption,
                                               callback: self.updatetxNotificationAlertSetting)
    }
    
    func updatetxNotificationAlertSetting(_ newOption: String?) {
        guard let selectedOption = newOption,
            let newSetting = NotificationAlert.allCases.first(where: { $0.localizedString == selectedOption }) else {
                return
        }
        
        self.walletSettings.setStringValue(newSetting.rawValue, for: "\(self.wallet.id_)\(DcrlibwalletIncomingTxNotificationsConfigKey)")
        self.incomingTxAlertButton.setTitle(newSetting.localizedString, for: .normal)
    }
    
     @IBAction func rescanBlockchain(_ sender: Any) {
        if SyncManager.shared.isSyncing {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.errorSyncInProgress)
        } else if !WalletLoader.shared.multiWallet.isConnectedToDecredNetwork() {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.notConnected)
        } else if SyncManager.shared.isRescanning {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.errorRescanInProgress)
        } else {
            // rescan blockchain
            self.showOkAlert(message: LocalizedStrings.rescanConfirm,
                                 title: LocalizedStrings.rescanBlockchain,
                                 onPressOk: self.rescanBlocks,
                                 addCancelAction: true)
        }
    }
        
    func rescanBlocks() {
        do {
            try WalletLoader.shared.multiWallet.rescanBlocks(self.wallet.id_)
            Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.rescanProgressNotification)
        } catch let error {
            let errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }

    @IBAction func removeWalletFromDevice(_ sender: Any) {
        if WalletLoader.shared.multiWallet.isConnectedToDecredNetwork() {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.disconnectDeleteWallet)
            return
        }
        self.showRemoveWalletWarning() { ok in
            guard ok else { return }
            
            if self.wallet.isWatchingOnlyWallet() {
                SimpleTextInputDialog.show(sender: self, title: LocalizedStrings.walletName, placeholder: LocalizedStrings.walletName, currentValue: self.wallet.name, verifyInput: true) { (walletName, dialogDelegate) in
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try WalletLoader.shared.multiWallet.delete(self.wallet.id_, privPass: nil)
                            DispatchQueue.main.async {
                                dialogDelegate?.dismissDialog()
                                self.walletDeleted()
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
            } else {
                Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: self.wallet.id_))
                    .with(prompt: LocalizedStrings.confirmToRemove)
                    .with(submitBtnText: LocalizedStrings.remove)
                    .requestCurrentCode(sender: self) { spendingCode, _, dialogDelegate in
                    
                        DispatchQueue.global(qos: .userInitiated).async {
                            do {
                                try WalletLoader.shared.multiWallet.delete(self.wallet.id_, privPass: spendingCode.utf8Bits)
                                DispatchQueue.main.async {
                                    dialogDelegate?.dismissDialog()
                                    self.walletDeleted()
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
    
    func showRemoveWalletWarning(callback: @escaping (Bool) -> Void) {
        let message = self.wallet.isWatchingOnlyWallet() ? LocalizedStrings.removeWalletWarning : LocalizedStrings.removeWatchWalletPrompt
        SimpleOkCancelDialog.show(sender: self,
                                  title: LocalizedStrings.removeWalletFromDevice,
                                  message: message,
                                  callback: callback)
    }
    
    func walletDeleted() {
        Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.walletRemoved)
        // todo clear wallet settings
        
        if WalletLoader.shared.multiWallet.openedWalletsCount() == 0 {
            Settings.clear()
            DispatchQueue.global(qos: .userInitiated).async {
                WalletLoader.shared.multiWallet.shutdown()
                DispatchQueue.main.async {
                    let startScreen = Storyboard.Main.initialViewController()
                    AppDelegate.shared.setAndDisplayRootViewController(startScreen!)
                }
            }
        } else {
            self.dismissView()
        }
    }
}
