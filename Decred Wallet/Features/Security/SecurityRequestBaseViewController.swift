//
//  SecurityRequestBaseViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

protocol SecurityRequestCompletionDelegate {
    func securityCodeProcessed(_ success: Bool, _ errorMessage: String?)
}

class SecurityRequestBaseViewController: SecurityBaseViewController, SecurityRequestCompletionDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!

    var isInErrorState = false
    var requestConfirmation = false
    var showCancelButton = false
    var prompt: String?
    var submitBtnText: String?
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var onUserEnteredSecurityCode: ((_ code: String, _ completionDelegate: SecurityRequestCompletionDelegate?) -> Void)?
    var onViewHeightChanged: ((_ height: CGFloat) -> Void)?
    var onLoadingStatusChanged: ((_ loading: Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.onViewHeightChanged?(self.containerView!.frame.size.height)
    }

    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    if endFrameY >= UIScreen.main.bounds.size.height {
                        self.stackViewBottomConstraint?.constant = 0.0
                    } else {
                        self.stackViewBottomConstraint?.constant = endFrame?.size.height ?? 0.0
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    func showError(text: String) {
        self.isInErrorState = true
    }

    func hideError() {
        self.isInErrorState = false
    }

    func securityCodeProcessed(_ success: Bool, _ errorMessage: String?) {
        if success {
            self.dismissView()
        } else if let errorMessage = errorMessage {
            self.showError(text: errorMessage)
        } else {
            self.showError(text: "Error")
        }
    }
}
