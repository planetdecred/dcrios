//
//  SecurityViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SecurityViewController: UIViewController {
    // `securityFor` is either `Startup` or `Spending`.
    var securityFor: Security.For!
    
    // `initialSecurityType` is either `Password` or `PIN`.
    var initialSecurityType: SecurityType!
    
    // true if this is an attempt to change a previously set security code
    var isSecurityCodeChangeAttempt: Bool = false

    // This will be triggered after a pin or password is provided by the user.
    var onSecurityCodeEntered: SecurityCodeRequestCallback?

    var tabController: UITabBarController?
    @IBOutlet weak var securityPromptLabel: UILabel!
    @IBOutlet weak var btnPin: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        // delay before activating initial tab to allow borders show properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.initialSecurityType == .password {
                self.activatePasswordTab()
            } else {
                self.activatePinTab()
            }
        }
    }

    func activatePasswordTab() {
        tabController?.selectedIndex = 0

        // add border below password tab and remove border below PIN tab
        btnPassword.addBorder(atPosition: .bottom, color: UIColor.appColors.primary, thickness: 2)
        btnPin.removeBorders(atPositions: .bottom)
        btnPin.addBorder(atPosition: .bottom, color: UIColor.appColors.surfaceRipple, thickness: 1)

        // set active and inactive text colors
        btnPassword.setTitleColor(UIColor.appColors.primary, for: .normal)
        btnPin.setTitleColor(UIColor.appColors.text4, for: .normal)

        if self.isSecurityCodeChangeAttempt {
            self.securityPromptLabel.text = String(format: "%@ %@ %@",
                                                   LocalizedStrings.change,
                                                   self.securityFor.localizedString.lowercased(),
                                                   LocalizedStrings.password.lowercased())
        } else {
            self.securityPromptLabel.text = String(format: LocalizedStrings.createPassword,
                                                   self.securityFor.localizedString.lowercased())
        }
    }

    func activatePinTab() {
        tabController?.selectedIndex = 1

        // add border below PIN tab and remove border below PIN tab
        btnPin.addBorder(atPosition: .bottom, color: UIColor.appColors.primary, thickness: 2)
        btnPassword.removeBorders(atPositions: .bottom)
        btnPassword.addBorder(atPosition: .bottom, color: UIColor.appColors.surfaceRipple, thickness: 1)

        // set active and inactive text colors
        btnPin.setTitleColor(UIColor.appColors.primary, for: .normal)
        btnPassword.setTitleColor(UIColor.appColors.text4, for: .normal)

        if self.isSecurityCodeChangeAttempt {
            self.securityPromptLabel.text = String(format: "%@ %@ %@",
                                                   LocalizedStrings.change,
                                                   self.securityFor.localizedString.lowercased(),
                                                   LocalizedStrings.pin)
        } else {
            self.securityPromptLabel.text = String(format: LocalizedStrings.createPIN,
                                                   self.securityFor.localizedString.lowercased())
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadTabBarController" {
            self.tabController = segue.destination as? UITabBarController
            self.tabController?.tabBar.isHidden = true

            let passwordTabVC = self.tabController?.viewControllers?.first as? RequestPasswordViewController
            self.setSecurityRequestParamAndCallbacks(for: passwordTabVC)

            let pinTabVC = self.tabController?.viewControllers?.last as? RequestPinViewController
            self.setSecurityRequestParamAndCallbacks(for: pinTabVC)
        }
    }
    
    private func setSecurityRequestParamAndCallbacks(for securityRequestVC: SecurityCodeRequestBaseViewController?) {
        securityRequestVC?.request = Security.Request(for: self.securityFor)
        securityRequestVC?.request.requestConfirmation = true
        securityRequestVC?.request.showCancelButton = true
        securityRequestVC?.request.isChangeAttempt = self.isSecurityCodeChangeAttempt
        
        securityRequestVC?.callbacks.onViewHeightChanged = { height in
            if self.containerViewHeightConstraint.constant == height {
                return
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self.containerViewHeightConstraint.constant = height
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        securityRequestVC?.callbacks.onLoadingStatusChanged = { loading in
            self.btnPin?.isEnabled = !loading
            self.btnPassword?.isEnabled = !loading
            
            let activeTabButton = securityRequestVC is RequestPasswordViewController ? self.btnPassword : self.btnPin
            activeTabButton?.addBorder(atPosition: .bottom,
                                      color: loading ? UIColor.appColors.text5: UIColor.appColors.primary,
                                      thickness: 2)
        }
        
        securityRequestVC?.callbacks.onSecurityCodeEntered = self.onSecurityCodeEntered
    }

    @IBAction func onPasswordTab(_ sender: Any) {
        guard self.tabController?.selectedIndex != 0 else { return }
        self.activatePasswordTab()
    }

    @IBAction func onPinTab(_ sender: Any) {
        guard self.tabController?.selectedIndex != 1 else { return }
        self.activatePinTab()
    }
}
