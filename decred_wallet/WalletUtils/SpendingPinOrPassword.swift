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
        if self.currentSecurityType() == "PASSWORD" {
            let requestPasswordVC = vc.storyboard!.instantiateViewController(withIdentifier: "RequestPasswordViewController") as! RequestPasswordViewController
            requestPasswordVC.prompt = "Enter Current Password"
            requestPasswordVC.onUserEnteredPinOrPassword = afterUserEntersPinOrPassword
            vc.navigationController?.pushViewController(requestPasswordVC, animated: true)
        } else {
            let requestPinVC = vc.storyboard!.instantiateViewController(withIdentifier: "RequestPinViewController") as! RequestPinViewController
            requestPinVC.prompt = "Enter Current PIN"
            requestPinVC.onUserEnteredPin = afterUserEntersPinOrPassword
            vc.navigationController?.pushViewController(requestPinVC, animated: true)
        }
    }
    
    private static func promptForNewPinOrPassword(_ vc: UIViewController, currentPinOrPassword: String) {
        // init secutity vc to use in getting new spending password or pin from user
        let securityVC = vc.storyboard!.instantiateViewController(withIdentifier: "SecurityViewController") as! SecurityViewController
        securityVC.pageTitlePrefix = "Change Spending"
        
        securityVC.onUserEnteredPinOrPassword = { (newPinOrPassword, securityType) in
            self.changeWalletSpendingPassphrase(vc, current: currentPinOrPassword, new: newPinOrPassword, type: securityType)
        }
        
        vc.navigationController?.pushViewController(securityVC, animated: true)
    }
    
    private static func changeWalletSpendingPassphrase(_ vc: UIViewController, current currentPassphrase: String, new newPassphrase: String, type securityType: String) {
        let currentSecurityType = self.currentSecurityType()!.lowercased()
        let progressHud = showProgressHud(with: "Changing spending \(currentSecurityType)...")
        
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
