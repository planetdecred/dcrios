//
//  PublicPassphrase.swift
//  Decred Wallet
//
//  Created by Wisdom Arerosuoghene on 27/04/2019.
//  Copyright © 2019 The Decred developers. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD

struct StartupPinOrPassword {
    static let defaultPublicPassphrase = "public"
    
    static func clear(sender vc: UIViewController) {
        if !self.pinOrPasswordIsSet() {
            // nothing to clear
            return
        }
        
        // pin/password was previously set, get the current pin/password before clearing
        self.promptForCurrentPinOrPassword(vc, afterUserEntersPinOrPassword: { currentPinOrPassword in
            self.changeWalletPublicPassphrase(vc, current: currentPinOrPassword, new: nil)
        })
    }
    
    // alias for set function
    static func change(sender vc: UIViewController) {
        self.set(sender: vc)
    }
    
    static func set(sender vc: UIViewController) {
        if !self.pinOrPasswordIsSet() {
            // pin/password was not previously set
            self.setNewPinOrPassword(vc, currentPinOrPassword: nil)
            return
        }
        
        // pin/password was previously set, get the current pin/password before proceeding
        self.promptForCurrentPinOrPassword(vc, afterUserEntersPinOrPassword: { currentPinOrPassword in
            self.setNewPinOrPassword(vc, currentPinOrPassword: currentPinOrPassword)
        })
    }
    
    static func promptForCurrentPinOrPassword(_ vc: UIViewController, afterUserEntersPinOrPassword: @escaping (String) -> Void) {
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
            vc.present(requestPinVC, animated: true, completion: nil)
        }
    }
    
    private static func setNewPinOrPassword(_ vc: UIViewController, currentPinOrPassword: String?) {
        // init secutity vc to use in getting new password or pin from user
        let securityVC = vc.storyboard!.instantiateViewController(withIdentifier: "SecurityViewController") as! SecurityViewController
        securityVC.pageTitlePrefix = "Create Startup" // "Password" or "Pin" will be appended when user selects the desired tab on the security vc
        
        securityVC.onUserEnteredPinOrPassword = { newPinOrPassword, securityType in
            self.changeWalletPublicPassphrase(vc, current: currentPinOrPassword, new: newPinOrPassword, type: securityType)
        }
        
        vc.navigationController?.pushViewController(securityVC, animated: true)
    }
    
    static func changeWalletPublicPassphrase(_ vc: UIViewController, current currentPassword: String?, new newPinOrPassword: String?, type securityType: String? = nil) {
        // cannot set new pin/password without a type specified
        if securityType == nil && newPinOrPassword != nil {
            vc.showOkAlert(message: "Security type not specified. Cannot proceed.", title: "Invalid request!")
            return
        }
        
        var progressHud: JGProgressHUD
        
        if currentPassword == nil {
            // password was not previously configured, let's set it
            progressHud = showProgressHud(with: "Securing wallet...")
        } else if newPinOrPassword == nil {
            // password was previously configured, but no new password is to be set
            let currentSecurityType = self.currentSecurityType()!.lowercased()
            progressHud = showProgressHud(with: "Removing startup \(currentSecurityType)...")
        } else {
            // password was previously configured, but we're to set a new one
            let currentSecurityType = self.currentSecurityType()!.lowercased()
            progressHud = showProgressHud(with: "Changing startup \(currentSecurityType)...")
        }
        
        let currentPublicPassphrase = currentPassword ?? self.defaultPublicPassphrase
        let newPublicPassphrase = newPinOrPassword ?? self.defaultPublicPassphrase
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let oldPublicPass = (currentPublicPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
                let newPublicPass = (newPublicPassphrase as NSString).data(using: String.Encoding.utf8.rawValue)!
                try SingleInstance.shared.wallet?.changePublicPassphrase(oldPublicPass, newPass: newPublicPass)
                
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    
                    if newPinOrPassword == "" {
                        UserDefaults.standard.set(false, forKey: GlobalConstants.SettingsKeys.IsStartupSecuritySet)
                        UserDefaults.standard.removeObject(forKey: GlobalConstants.SettingsKeys.StartupSecurityType)
                    } else {
                        UserDefaults.standard.set(true, forKey: GlobalConstants.SettingsKeys.IsStartupSecuritySet)
                        UserDefaults.standard.setValue(securityType, forKey: GlobalConstants.SettingsKeys.StartupSecurityType)
                    }
                    
                    UserDefaults.standard.synchronize()
                }
                return
            } catch let error {
                DispatchQueue.main.async {
                    progressHud.dismiss()
                    vc.showOkAlert(message: error.localizedDescription, title: "Error")
                }
            }
        }
    }
    
    static func pinOrPasswordIsSet() -> Bool {
        return UserDefaults.standard.bool(forKey: GlobalConstants.SettingsKeys.IsStartupSecuritySet)
    }
    
    static func currentSecurityType() -> String? {
        return UserDefaults.standard.string(forKey: GlobalConstants.SettingsKeys.StartupSecurityType)
    }
}
