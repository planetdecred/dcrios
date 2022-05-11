//
//  SettingsController.swift
//  Decred Wallet

// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import JGProgressHUD
import Dcrlibwallet
import LocalAuthentication
import SwiftKeychainWrapper

class SettingsController: UITableViewController  {
    @IBOutlet weak var changeStartPINCell: UITableViewCell!
    @IBOutlet weak var cellularSyncSwitch: UISwitch!
    @IBOutlet weak var connectPeerIpLabel: UILabel!
    @IBOutlet weak var spendUnconfirmedFundSwitch: UISwitch!
    @IBOutlet weak var beepForNewBlockSwitch: UISwitch!
    @IBOutlet weak var politeiaNotificationSwitch: UISwitch!
    @IBOutlet weak var startupPinOrPasswordSwitch: UISwitch!
    @IBOutlet weak var useBiometricSwitch: UISwitch!
    @IBOutlet weak var currencySubtitleLabel: UILabel!
    @IBOutlet weak var connectIpLabel: UILabel!
    @IBOutlet weak var biometricTypeLabel: UILabel!
    @IBOutlet weak var colorThemeSubtitleLabel: UILabel!
    @IBOutlet weak var governanceSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spendUnconfirmedFundSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.beepForNewBlockSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.politeiaNotificationSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.cellularSyncSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.governanceSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    @objc func switchChanged(switchView: UISwitch) {
        var fieldToUpdate: String?
        switch switchView {
        case self.spendUnconfirmedFundSwitch:
            fieldToUpdate = DcrlibwalletSpendUnconfirmedConfigKey
            
        case self.beepForNewBlockSwitch:
            fieldToUpdate = DcrlibwalletBeepNewBlocksConfigKey
            break
            
        case self.cellularSyncSwitch:
            fieldToUpdate = DcrlibwalletSyncOnCellularConfigKey
            
        case self.politeiaNotificationSwitch:
            fieldToUpdate = DcrlibwalletPoliteiaNotificationConfigKey
            
        case self.governanceSwitch:
            fieldToUpdate = GlobalConstants.Strings.GOVERNANCE_SETTING
            self.tableView.reloadData()
            
        default:
            return
        }
        
        if fieldToUpdate != nil {
            Settings.setBoolValue(switchView.isOn, for: fieldToUpdate!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.text1
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
        self.navigationController?.navigationBar.barTintColor = UIColor.appColors.background
        self.navigationController?.navigationBar.shadowImage = UIImage()
        if self.traitCollection.userInterfaceStyle == .dark {
            self.navigationController?.navigationBar.barTintColor = UIColor.black
        }
        let icon = self.navigationController?.modalPresentationStyle == .fullScreen ?  UIImage(named: "ic_close") : UIImage(named: "left-arrow")
        let closeButton = UIBarButtonItem(image: icon,
                                          style: .done,
                                          target: self,
                                          action: #selector(self.dismissView))
        
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.settings, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.text1
        
        self.navigationItem.leftBarButtonItems =  [closeButton, barButtonTitle]
        
        self.loadSettingsData()
        self.checkStartupSecurity()
    }
    
    func loadSettingsData() -> Void {
        self.spendUnconfirmedFundSwitch?.isOn = Settings.readBoolValue(for: DcrlibwalletSpendUnconfirmedConfigKey)
        self.connectPeerIpLabel?.text = Settings.readStringValue(for: DcrlibwalletSpvPersistentPeerAddressesConfigKey)
        self.beepForNewBlockSwitch?.isOn = Settings.readBoolValue(for: DcrlibwalletBeepNewBlocksConfigKey)
        self.politeiaNotificationSwitch?.isOn = Settings.readBoolValue(for: DcrlibwalletPoliteiaNotificationConfigKey)
        self.cellularSyncSwitch.isOn = Settings.readBoolValue(for: DcrlibwalletSyncOnCellularConfigKey)
        self.useBiometricSwitch.isOn = Settings.readBoolValue(for: DcrlibwalletUseBiometricConfigKey)
        self.governanceSwitch.isOn = Settings.readBoolValue(for: GlobalConstants.Strings.GOVERNANCE_SETTING)
        
        switch Settings.currencyConversionOption {
        case .None:
            self.currencySubtitleLabel?.text = LocalizedStrings.none
        case .Bittrex:
            self.currencySubtitleLabel?.text = "USD (bittrex)"
        }
        
        switch Settings.colorThemeOption {
        case .deviceDefault:
            self.colorThemeSubtitleLabel.text = LocalizedStrings.deviceDefault
        case .light:
            self.colorThemeSubtitleLabel?.text = LocalizedStrings.light
        case .dark:
            self.colorThemeSubtitleLabel?.text = LocalizedStrings.dark
        }
    }
    
    func checkStartupSecurity() {
        self.startupPinOrPasswordSwitch?.setOn(StartupPinOrPassword.pinOrPasswordIsSet(), animated: false)
        
        self.useBiometricSwitch?.setOn(Settings.readBoolValue(for: DcrlibwalletUseBiometricConfigKey), animated: false)
        
        if startupPinOrPasswordSwitch.isOn {
            self.changeStartPINCell.isUserInteractionEnabled = true
            self.changeStartPINCell.alpha = 1
        }
        else{
            self.changeStartPINCell.isUserInteractionEnabled = false
            self.changeStartPINCell.alpha = 0.4
        }
        
        self.tableView.reloadData()
    }
    
    @objc override func dismissView() {
        if self.isModal {
            self.dismiss(animated: false, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return LocalizedStrings.general.capitalized
        case 1:
            return LocalizedStrings.security.capitalized
        case 2:
            return LocalizedStrings.notifications.capitalized
        case 3:
            return LocalizedStrings.connection.capitalized
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 3:
            return LocalizedStrings.userAgentInfo
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.appColors.text2
        header.textLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 14)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.textColor = UIColor.appColors.text4
        footer.textLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 14)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var isWalletOpen = false
        if WalletLoader.shared.multiWallet.openedWalletsCount() > 0 {
            isWalletOpen = true
        }
        
        var isBiometricSupported = false
        let (result, _) = LocalAuthentication.isBiometricSupported()
        if let text = result {
            self.biometricTypeLabel.text = text
            isBiometricSupported = true
        }
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if #available(iOS 13.0, *) {
                    return 44
                } else {
                    return 0
                }
                
            default:
                return 44
            }
        }
        
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0: // enable startup pin/password, requires wallet to be opened.
                return isWalletOpen ? 44 : 0
                
            case 1: // use biometrics, requires wallet to be opened, startup pin/password to have been enabled previously and biometric supported on the device.
                return isWalletOpen && startupPinOrPasswordSwitch.isOn && isBiometricSupported ? 44 : 0
                
            case 2: // change startup pin/password, requires wallet to be opened and startup pin to have been enabled previously.
                return isWalletOpen && startupPinOrPasswordSwitch.isOn ? 44 : 0
                
            default:
                return 44
            }
        }
        
        if indexPath == IndexPath.init(row: 1, section: 2) {
            return self.governanceSwitch.isOn ? 44 : 0
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1: // SECURITY
            switch indexPath.row {
            case 0: // enable/disable startup pin/password
                if startupPinOrPasswordSwitch.isOn {
                    StartupPinOrPassword.clear(sender: self, done: self.checkStartupSecurity)
                } else {
                    StartupPinOrPassword.set(sender: self, done: self.checkStartupSecurity)
                }
                
            case 1: // use biometric
                let prompt = String(format: LocalizedStrings.enableWithStartupCode,
                StartupPinOrPassword.currentSecurityType().localizedString)
                self.promptForStartupPinOrPassword(submitBtnText: LocalizedStrings.verify, prompt: prompt) { pinOrPassword, _, dialogDelegate in
                    self.verifyStartupPinOrPasswordAndToggleBiometricsUsage(startupPinOrPassword: pinOrPassword, dialogDelegate: dialogDelegate)
                }
                
            case 2: // change startup pin/password
                StartupPinOrPassword.change(sender: self, done: self.checkStartupSecurity)
                
            default:
                break
            }
            
        case 3: // CONNECTION
            switch indexPath.row {
            case 2: // user agent
                SimpleTextInputDialog.show(sender: self, title: LocalizedStrings.setupUserAgent, placeholder: LocalizedStrings.userAgent, currentValue: Settings.readStringValue(for: DcrlibwalletUserAgentConfigKey), submitButtonText: LocalizedStrings.confirm) { userAgent, dialogDelegate in
                    dialogDelegate?.dismissDialog()
                    Settings.setStringValue(userAgent, for: DcrlibwalletUserAgentConfigKey)
                }
                
            default:
                break
            }
            
        default:
            break
        }
    }
    
    func promptForStartupPinOrPassword(submitBtnText: String, prompt: String, callback: @escaping SecurityCodeRequestCallback) {
        let prompt = String(format: LocalizedStrings.enableWithStartupCode,
                            StartupPinOrPassword.currentSecurityType().localizedString)
        
        Security.startup()
            .with(prompt: prompt)
            .with(submitBtnText: submitBtnText)
            .should(showCancelButton: true)
            .requestCurrentCode(sender: self, callback: callback)
    }
    
    func verifyStartupPinOrPasswordAndToggleBiometricsUsage(startupPinOrPassword: String, dialogDelegate: InputDialogDelegate?) {

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try WalletLoader.shared.multiWallet.verifyStartupPassphrase(startupPinOrPassword.utf8Bits)
                DispatchQueue.main.async {
                    dialogDelegate?.dismissDialog()
                    self.useBiometricSwitch.setOn(!self.useBiometricSwitch.isOn, animated: true)
                    Settings.setBoolValue(self.useBiometricSwitch.isOn, for: DcrlibwalletUseBiometricConfigKey)

                    if self.useBiometricSwitch.isOn {
                        KeychainWrapper.standard.set(startupPinOrPassword, forKey: "StartupPinOrPassword")
                    } else {
                        KeychainWrapper.standard.removeObject(forKey: "StartupPinOrPassword")
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    if error.isInvalidPassphraseError {
                        dialogDelegate?.displayPassphraseError(errorMessage: StartupPinOrPassword.invalidSecurityCodeMessage())
                    } else {
                        dialogDelegate?.displayError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
}
