//
//  SecurityViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SecurityViewController: UIViewController {
    // "Password" or "Pin" will be appended to the title depending on what tab is activated
    var securityFor = LocalizedStrings.spending // or Startup
    var initialSecurityType: String? // determines which tab will be displayed first
    
    // This will be triggered after a pin or password is provided by the user.
    var onSecurityCodeEntered: SecurityCodeRequestCallback?

    var tabController: UITabBarController?
    @IBOutlet weak var securityPromptLabel: UILabel!
    @IBOutlet weak var btnPin: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!

    private func updateContainerViewHeight(height: CGFloat) {
        DispatchQueue.main.async {
            if self.containerViewHeightConstraint.constant != height {
                UIView.animate(withDuration: 0.1) {
                    self.containerViewHeightConstraint.constant = height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadTabBarController" {
            self.tabController = segue.destination as? UITabBarController
            self.tabController?.tabBar.isHidden = true

            let passwordTabVC = self.tabController?.viewControllers?.first as? RequestPasswordViewController
            self.setSecurityRequestParamsAndCallbacks(for: passwordTabVC)

            let pinTabVC = self.tabController?.viewControllers?.last as? RequestPinViewController
            self.setSecurityRequestParamsAndCallbacks(for: pinTabVC)
        }
    }
    
    private func setSecurityRequestParamsAndCallbacks(for securityRequestVC: SecurityRequestBaseViewController?) {
        securityRequestVC?.request.for = self.securityFor
        securityRequestVC?.request.requestConfirmation = true
        securityRequestVC?.request.showCancelButton = true
        
        securityRequestVC?.callbacks.onViewHeightChanged = updateContainerViewHeight
        securityRequestVC?.callbacks.onLoadingStatusChanged = { (loading: Bool) in
            self.btnPin?.isEnabled = !loading
            self.btnPassword?.isEnabled = !loading
            self.btnPassword.addBorder(atPosition: .bottom,
                                       color: loading ? UIColor.appColors.darkGray: UIColor.appColors.lightBlue,
                                       thickness: 2)
        }
        securityRequestVC?.callbacks.onSecurityCodeEntered = self.onSecurityCodeEntered
    }

    override func viewDidLoad() {
        // delay before activating initial tab to allow borders show properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.initialSecurityType == SecurityType.pin.rawValue {
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

        // add border below password tab and remove border below PIN tab
        btnPassword.addBorder(atPosition: .bottom, color: UIColor.appColors.lightBlue, thickness: 2)
        btnPin.removeBorders(atPositions: .bottom)
        btnPin.addBorder(atPosition: .bottom, color: UIColor.appColors.gray, thickness: 1)

        // set active and inactive text colors
        btnPassword.setTitleColor(UIColor.appColors.lightBlue, for: .normal)
        btnPin.setTitleColor(UIColor.appColors.bluishGray, for: .normal)

        self.securityPromptLabel.text = String(format: LocalizedStrings.createPassword, self.securityFor.lowercased())
    }

    func activatePinTab() {
        tabController?.selectedIndex = 1

        // add border below PIN tab and remove border below PIN tab
        btnPin.addBorder(atPosition: .bottom, color: UIColor.appColors.lightBlue, thickness: 2)
        btnPassword.removeBorders(atPositions: .bottom)
        btnPassword.addBorder(atPosition: .bottom, color: UIColor.appColors.gray, thickness: 1)

        // set active and inactive text colors
        btnPin.setTitleColor(UIColor.appColors.lightBlue, for: .normal)
        btnPassword.setTitleColor(UIColor.appColors.bluishGray, for: .normal)

        self.securityPromptLabel.text = String(format: LocalizedStrings.createPIN, self.securityFor.lowercased())
    }
}
