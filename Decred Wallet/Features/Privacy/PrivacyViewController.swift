//
//  PrivacyViewController.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit
import Dcrlibwallet

class PrivacyViewController: UIViewController {
    
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var mixerStatusInfo: UILabel!
    @IBOutlet weak var unmixedBalance: UILabel!
    @IBOutlet weak var mixedBalance: UILabel!
    @IBOutlet weak var mixedAccountLabel: UILabel!
    @IBOutlet weak var unmixedAccountLabel: UILabel!
    @IBOutlet weak var mixedAccountBranch: UILabel!
    @IBOutlet weak var shuffleServer: UILabel!
    @IBOutlet weak var shufflePort: UILabel!
    @IBOutlet weak var mixerSwitch: UISwitch!
    @IBOutlet weak var spendUnmixedSwitch: UISwitch!
    @IBOutlet weak var mixerStatusIcon: UIImageView!
    @IBOutlet weak var mixingInfo: UILabel!
    
    @IBOutlet weak var mixerDetailViewConst: NSLayoutConstraint!
    @IBOutlet weak var mixerDropdownArrow: UIImageView!
    
    private var mixedAccountNumber: Int = -1
    private var unmixedAccountNumber: Int = -1
    
    var wallet: DcrlibwalletWallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.walletName.text = wallet.name
        
        let txNotificationListener = self as DcrlibwalletTxAndBlockNotificationListenerProtocol
        try? WalletLoader.shared.multiWallet.add(txNotificationListener, uniqueIdentifier: "\(self)")
        
        WalletLoader.shared.multiWallet.setAccountMixerNotification(self)
        
        self.mixedAccountNumber = wallet.readIntConfigValue(forKey: DcrlibwalletAccountMixerMixedAccount, defaultValue: -1)
        self.unmixedAccountNumber = wallet.readIntConfigValue(forKey: DcrlibwalletAccountMixerUnmixedAccount, defaultValue: -1)
        
        self.updateMixerSettingsInfo()
        
        if wallet.isAccountMixerActive() {
            mixerSwitch.isOn = true
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        self.setMixerStatus()
    }
    
    func updateMixerSettingsInfo() {
        var error: NSError?
        self.mixedAccountLabel.text =  wallet.accountName(Int32(mixedAccountNumber), error: &error)
        self.unmixedAccountLabel.text =  wallet.accountName(Int32(unmixedAccountNumber), error: &error)
        self.mixedAccountBranch.text = DcrlibwalletMixedAccountBranch.description
        self.shuffleServer.text = DcrlibwalletShuffleServer.description
        var shufflePort: String {
            if BuildConfig.IsTestNet {
                return DcrlibwalletTestnetShufflePort.description
            } else {
                return DcrlibwalletMainnetShufflePort.description
            }
        }
        self.shufflePort.text = shufflePort
    }
    
    @IBAction func privacyInfo(_ sender: Any) {
        SimpleAlertDialog.show(sender: self,
                               title: LocalizedStrings.mixerHelperTitle,
                               attribMessage: LocalizedStrings.mixerHelperDsc.htmlToAttributedString,
                                  okButtonText: LocalizedStrings.gotIt,
                                  callback: nil)
    }
    @IBAction func dismissView(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func showReminder(callback: @escaping (Bool) -> Void) {
    }
    
    @objc func appMovedToForeground() {
        let txNotificationListener = self as DcrlibwalletTxAndBlockNotificationListenerProtocol
        try? WalletLoader.shared.multiWallet.add(txNotificationListener, uniqueIdentifier: "\(self)")
        self.setMixerStatus()
    }
    
    @objc func appMovedToBackground() {
        WalletLoader.shared.multiWallet.removeTxAndBlockNotificationListener("\(self)")
    }
    
    @IBAction func mixAccount(_ sender: Any) {
        self.mixerSwitch.isOn = wallet.isAccountMixerActive()
        if wallet.isAccountMixerActive() {
            self.stopAccountMixer()
        } else {
            self.showWarningAndStartMixer()
        }
    }
    
    func stopAccountMixer() {
         do {
            try WalletLoader.shared.multiWallet.stopAccountMixer(self.wallet.id_)
         } catch let error {
             DispatchQueue.main.async {
                Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
             }
         }
    }
    
    func showWarningAndStartMixer() {
        if SyncManager.shared.isSyncing {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.errorSyncInProgress)
            return
        } else if !WalletLoader.shared.multiWallet.isConnectedToDecredNetwork() {
            Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.notConnected)
            return
        }
        
        self.showStartWarning { (ok) in
            guard ok else { return }
            Security.spending(initialSecurityType: SpendingPinOrPassword.securityType(for: self.wallet.id_))
                .with(prompt: LocalizedStrings.unlockToStartMixing)
                .with(submitBtnText: LocalizedStrings.confirm)
                .requestCurrentCode(sender: self) { spendingCode, _, dialogDelegate in
                
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                             try WalletLoader.shared.multiWallet.startAccountMixer(self.wallet.id_, walletPassphrase: spendingCode)
                             DispatchQueue.main.async {
                                self.mixerSwitch.isOn = true
                                dialogDelegate?.dismissDialog()
                             }
                         } catch let error {
                            var errorMessage = error.localizedDescription
                            if error.isInvalidPassphraseError {
                                errorMessage = SpendingPinOrPassword.invalidSecurityCodeMessage(for: self.wallet.id_)
                                DispatchQueue.main.async {
                                    dialogDelegate?.displayError(errorMessage: errorMessage)
                                    self.mixerSwitch.isOn = false
                                }
                            } else if error.localizedDescription == DcrlibwalletErrNoMixableOutput {
                                DispatchQueue.main.async {
                                    Utils.showBanner(in: self.view, type: .error, text: LocalizedStrings.noMixableOutput)
                                    dialogDelegate?.dismissDialog()
                                    self.mixerSwitch.isOn = false
                                }
                            } else {
                                DispatchQueue.main.async {
                                    Utils.showBanner(in: self.view, type: .error, text:errorMessage)
                                    dialogDelegate?.dismissDialog()
                                    self.mixerSwitch.isOn = false
                                }
                            }
                         }
                    }
                }
        }
    }
    
    func showStartWarning(callback: @escaping (Bool) -> Void) {
        SimpleOkCancelDialog.show(sender: self, title: "",
                                  message: LocalizedStrings.startMixerWarning,
                                  okButtonText: LocalizedStrings.continueText,
                                  callback: callback)
    }
    
    func setMixerStatus() {
        if self.wallet.isAccountMixerActive() {
            DispatchQueue.main.async {
                self.mixerStatusInfo.text = LocalizedStrings.keepThisAppOpened
                self.mixerStatusInfo.textColor = UIColor.appColors.darkBluishGray
                self.mixerDetailViewConst.constant = 104
                self.mixerStatusIcon.image = UIImage(named: "ic_alert")
                self.mixerDropdownArrow.isHidden = false
                self.mixingInfo.isHidden = false
            }
        } else {
            let retV = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
            
            do{
                try WalletLoader.shared.multiWallet.ready(toMix: self.wallet.id_, ret0_: retV)
                DispatchQueue.main.async {
                    if (retV[0]).boolValue {
                        self.mixerStatusInfo.text = LocalizedStrings.readyToMix
                        self.mixerStatusInfo.textColor = UIColor.appColors.darkBluishGray
                        return
                    } else {
                        self.mixerStatusInfo.text = LocalizedStrings.noMixableOutput
                        self.mixerStatusInfo.textColor = UIColor.appColors.orange
                        return
                    }
                }
            } catch {
                DispatchQueue.main.async {
                   Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
                }
            }
            
            DispatchQueue.main.async {
                self.mixerDetailViewConst.constant = 72
                self.mixerDropdownArrow.isHidden = true
                self.mixingInfo.isHidden = true
            }
        }
        
        self.updateBalance()
    }
    
    func updateBalance() {
        do {
            let unmixedBalance = try wallet?.getAccountBalance(Int32(unmixedAccountNumber))
            let mixedBalance = try wallet?.getAccountBalance(Int32(mixedAccountNumber))
            DispatchQueue.main.async {
                self.unmixedBalance.text = Utils.amountAsAttributedString(amount: unmixedBalance?.dcrTotal, smallerTextSize: 15.0).string
                self.mixedBalance.text = Utils.amountAsAttributedString(amount: mixedBalance?.dcrTotal, smallerTextSize: 15.0).string
            }
        } catch {
            DispatchQueue.main.async {
                Utils.showBanner(in: self.view, type: .error, text: error.localizedDescription)
            }
        }
    }
}

extension PrivacyViewController: DcrlibwalletAccountMixerNotificationListenerProtocol {
    func onAccountMixerEnded(_ walletID: Int) {
        
        if self.wallet.id_ == walletID {
            DispatchQueue.main.async {
                self.setMixerStatus()
                self.mixerSwitch.isOn = false
                Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.mixerHasStoppedRunning)
            }
        }
    }
    
    func onAccountMixerStarted(_ walletID: Int) {
        
        if self.wallet.id_ == walletID {
            DispatchQueue.main.async {
                self.setMixerStatus()
                self.mixerSwitch.isOn = true
                Utils.showBanner(in: self.view, type: .success, text: LocalizedStrings.mixerIsRuning)
            }
        }
    }
}

extension PrivacyViewController: DcrlibwalletTxAndBlockNotificationListenerProtocol {
    
    func onBlockAttached(_ walletID: Int, blockHeight: Int32) {
        self.setMixerStatus()
    }
    
    func onTransaction(_ transaction: String?) {}
    func onTransactionConfirmed(_ walletID: Int, hash: String?, blockHeight: Int32) {}
}
