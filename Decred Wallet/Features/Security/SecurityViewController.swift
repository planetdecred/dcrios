//
//  SecurityViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SecurityViewController: SecurityBaseViewController {
    static let SECURITY_TYPE_PASSWORD = "PASSWORD"
    static let SECURITY_TYPE_PIN = "PIN"
    
    // "Password" or "Pin" will be appended to the title depending on what tab is activated
    var securityFor = "Spending" // or Startup
    var initialSecurityType: String? // determines which tab will be displayed first
    
    // This will be triggered after a pin or password is provided by the user.
    var onUserEnteredPinOrPassword: ((_ pinOrPassword: String, _ securityType: String) -> Void)?
    
    var tabController: UITabBarController?
    @IBOutlet weak var btnPin: Button!
    @IBOutlet weak var btnPassword: Button!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadTabBarController" {
            self.tabController = segue.destination as? UITabBarController
            self.tabController?.tabBar.isHidden = true
            
            let passwordTabVC = self.tabController?.viewControllers?.first as? PasswordSetupViewController
            passwordTabVC?.securityFor = self.securityFor
            passwordTabVC?.onUserEnteredPassword = { password in
                self.navigationController?.popViewController(animated: true)
                self.onUserEnteredPinOrPassword?(password, SecurityViewController.SECURITY_TYPE_PASSWORD)
            }
            
            let pinTabVC = self.tabController?.viewControllers?.last as? RequestPinViewController
            pinTabVC?.securityFor = self.securityFor
            pinTabVC?.requestPinConfirmation = true
            pinTabVC?.onUserEnteredPin = { pin in
                self.navigationController?.popViewController(animated: true)
                self.onUserEnteredPinOrPassword?(pin, SecurityViewController.SECURITY_TYPE_PIN)
            }
            
            if self.initialSecurityType == SecurityViewController.SECURITY_TYPE_PIN {
                self.activatePinTab()
            }else{
                self.activatePasswordTab()
            }
        }
    }

    @IBAction func onPasswordTab(_ sender: Any) {
        self.activatePasswordTab()
    }
    
    @IBAction func onPinTab(_ sender: Any) {
        self.activatePinTab()
    }
    
    func activatePasswordTab() {
        tabController?.selectedIndex = 0
        btnPassword.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9647058824, alpha: 1)
        btnPin.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Remove border from inactive and set on active        
        btnPassword.border(at: "right")
        btnPassword.border(at: "bottom")
        btnPin.removeBorders()
        
    }
    
    func activatePinTab() {
        tabController?.selectedIndex = 1
        btnPin.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9647058824, alpha: 1)
        btnPassword.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Remove border from inactive and set on active
        btnPin.border(at: "left")
        btnPin.border(at: "bottom")
        btnPassword.removeBorders()
        
    }
}
