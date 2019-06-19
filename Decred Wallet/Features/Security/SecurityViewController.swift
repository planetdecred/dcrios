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
    var securityFor = "spending".localized // or Startup
    var initialSecurityType: String? // determines which tab will be displayed first
    
    // This will be triggered after a pin or password is provided by the user.
    var onUserEnteredPinOrPassword: ((_ pinOrPassword: String, _ securityType: String) -> Void)?
    
    var tabController: UITabBarController?
    @IBOutlet weak var btnPin: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    
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
        }
    }
    
    override func viewDidLoad() {
        // delay before activating initial tab to allow borders show properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.initialSecurityType == SecurityViewController.SECURITY_TYPE_PIN {
                self.activatePinTab()
            } else {
                self.activatePasswordTab()
            }
        }
    }

    @IBAction func onPasswordTab(_ sender: Any) {
        guard self.tabController?.selectedIndex != 0 else { return }
        self.activatePasswordTab()
    }
    
    @IBAction func onPinTab(_ sender: Any) {
        guard self.tabController?.selectedIndex != 1 else { return }
        self.activatePinTab()
    }
    
    func activatePasswordTab() {
        tabController?.selectedIndex = 0
        // activate password button
        btnPassword.backgroundColor = UIColor.appColors.offWhite
        btnPassword.removeBorders(atPositions: .right, .bottom)
        // deactivate pin button
        btnPassword.setTitleColor(UIColor.appColors.tabActive, for: .normal)
        btnPassword.addBorder(atPosition: .bottom)
    }
    
    func activatePinTab() {
        tabController?.selectedIndex = 1
        // activate pin button
        btnPin.backgroundColor = UIColor.appColors.offWhite
        btnPin.removeBorders(atPositions: .left, .bottom)
        // deactivate password button
        btnPassword.backgroundColor = UIColor.white
        btnPassword.addBorders(atPositions: [.right, .bottom])
    }
}
