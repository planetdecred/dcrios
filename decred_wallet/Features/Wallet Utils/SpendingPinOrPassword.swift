//
//  PrivatePassphrase.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 27/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import UIKit

struct SpendingPinOrPassword {
    static func change(sender vc: UIViewController) {
        self.promptForCurrentPinOrPassword(vc, afterUserEntersPinOrPassword: { (currentPinOrPassword: String) in
            self.promptForNewPinOrPassword(vc, currentPinOrPassword: currentPinOrPassword)
        })
    }
    
    private static func promptForCurrentPinOrPassword(_ vc: UIViewController, afterUserEntersPinOrPassword: @escaping (String) -> Void) {
        // show the appropriate vc to read current pin or password
        if self.currentSecurityType() == SecurityViewController.SECURITY_TYPE_PASSWORD {
            let requestPasswordVC = RequestPasswordViewController.instantiate()
            requestPasswordVC.prompt = "Enter Current Spending Password"
            requestPasswordVC.onUserEnteredPassword = afterUserEntersPinOrPassword
            vc.present(requestPasswordVC, animated: true)
        } else {
            let requestPinVC = RequestPinViewController.instantiate()
            requestPinVC.securityFor = "Current"
            requestPinVC.showCancelButton = true
            requestPinVC.onUserEnteredPin = afterUserEntersPinOrPassword
            vc.present(requestPinVC, animated: true)
        }
    }
    
    private static func promptForNewPinOrPassword(_ vc: UIViewController, currentPinOrPassword: String) {
        // init secutity vc to use in getting new spending password or pin from user
        let securityVC = SecurityViewController.instantiate()
        securityVC.securityFor = "Spending"
        securityVC.initialSecurityType = self.currentSecurityType()
        
        securityVC.onUserEnteredPinOrPassword = { (newPinOrPassword, securityType) in
            self.changeWalletSpendingPassphrase(vc, current: currentPinOrPassword, new: newPinOrPassword, type: securityType)
        }
        
        vc.navigationController?.pushViewController(securityVC, animated: true)
    }
    
    private static func changeWalletSpendingPassphrase(_ vc: UIViewController, current currentPassphrase: String, new newPassphrase: String, type securityType: String) {
        let newSecurityType = securityType.lowercased()
        let progressHud = Utils.showProgressHud(with: "Changing spending \(newSecurityType)...")
        
        let oldPrivatePass = (currentPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        let newPrivatePass = (newPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try SingleInstance.shared.wallet?.changePrivatePassphrase(oldPrivatePass, newPass: newPrivatePass)
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    UserDefaults.standard.setValue(securityType, forKey: GlobalConstants.SettingsKeys.SpendingPassphraseSecurityType)
                    UserDefaults.standard.synchronize()
                }
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    vc.showOkAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    static func currentSecurityType() -> String? {
        return UserDefaults.standard.string(forKey: GlobalConstants.SettingsKeys.SpendingPassphraseSecurityType)
    }
}
