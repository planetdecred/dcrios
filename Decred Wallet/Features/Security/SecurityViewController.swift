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
    var securityFor = LocalizedStrings.spending // or Startup
    var initialSecurityType: String? // determines which tab will be displayed first

    // This will be triggered after a pin or password is provided by the user.
    var onUserEnteredPinOrPassword: ((_ code: String,
                                      _ securityType: String,
                                      _ completionDelegate: SecurityRequestCompletionDelegate?) -> Void)?

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
            passwordTabVC?.securityFor = self.securityFor
            passwordTabVC?.requestConfirmation = true
            passwordTabVC?.showCancelButton = true
            passwordTabVC?.onViewHeightChanged = updateContainerViewHeight
            passwordTabVC?.onLoadingStatusChanged = { (loading: Bool) in
                self.btnPin?.isEnabled = !loading
                self.btnPassword?.isEnabled = !loading
                self.btnPassword.addBorder(atPosition: .bottom,
                                           color: loading ? UIColor.appColors.darkGray: UIColor.appColors.lightBlue,
                                           thickness: 2)
            }
            passwordTabVC?.onUserEnteredSecurityCode = { (code: String, completionDelegate: SecurityRequestCompletionDelegate?) in
                self.onUserEnteredPinOrPassword?(code, SecurityViewController.SECURITY_TYPE_PASSWORD, completionDelegate)
            }

            let pinTabVC = self.tabController?.viewControllers?.last as? RequestPinViewController
            pinTabVC?.securityFor = self.securityFor
            pinTabVC?.requestConfirmation = true
            pinTabVC?.showCancelButton = true
            pinTabVC?.onViewHeightChanged = updateContainerViewHeight
            pinTabVC?.onLoadingStatusChanged = { (loading: Bool) in
                self.btnPin?.isEnabled = !loading
                self.btnPassword?.isEnabled = !loading
                self.btnPin.addBorder(atPosition: .bottom,
                                           color: loading ? UIColor.appColors.darkGray: UIColor.appColors.lightBlue,
                                           thickness: 2)
            }
            pinTabVC?.onUserEnteredSecurityCode = { (code: String, completionDelegate: SecurityRequestCompletionDelegate?) in
                self.onUserEnteredPinOrPassword?(code, SecurityViewController.SECURITY_TYPE_PIN, completionDelegate)
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
