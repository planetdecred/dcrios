//
//  SecurityRequestBaseViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

// triggered when security code is entered by user
typealias SecurityCodeRequestCallback = (_ code: String, _ type: SecurityType, _ completion: SecurityCodeRequestCompletionDelegate?) -> Void

// triggered after a user enters his current code and then a new code
typealias CurrentAndNewSecurityCodeRequestCallback = (_ currentCode: String,
    _ currentCodeRequestCompletion: SecurityCodeRequestCompletionDelegate?,
    _ newCode: String,
    _ newCodeRequestCompletion: SecurityCodeRequestCompletionDelegate?,
    _ newCodeType: SecurityType) -> Void

// triggered after user-provided code is processed
protocol SecurityCodeRequestCompletionDelegate {
    func securityCodeProcessed()
    func securityCodeError(errorMessage: String)
}

class SecurityCodeRequestBaseViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    var request: Security.Request!
    var callbacks = Security.RequestCallbacks()
    
    var isInErrorState = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.callbacks.onViewHeightChanged?(self.containerView!.frame.size.height)
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
}

extension SecurityCodeRequestBaseViewController: SecurityCodeRequestCompletionDelegate {
    func securityCodeProcessed() {
        self.dismissView()
    }
    
    func securityCodeError(errorMessage: String) {
        self.showError(text: errorMessage)
    }
}
