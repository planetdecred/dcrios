//
//  SecurityRequestBaseViewController.swift
//  Decred Wallet
//
// Copyright (c) 2019-2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

// triggered when security code is entered by user
typealias SecurityCodeRequestCallback = (_ code: String, _ type: SecurityType, _ dialogDelegate: InputDialogDelegate?) -> Void

// triggered after a user enters his current code and then a new code
typealias CurrentAndNewSecurityCodeRequestCallback = (_ currentCode: String,
    _ currentCodeRequestDelegate: InputDialogDelegate?,
    _ newCode: String,
    _ newCodeRequestDelegate: InputDialogDelegate?,
    _ newCodeType: SecurityType) -> Void

class SecurityCodeRequestBaseViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    var request: Security.Request!
    var callbacks = Security.RequestCallbacks()
    
    var isInErrorState = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listenForKeyboardVisibilityChanges(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // disable swipe down from dismissing dialog
        self.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.callbacks.onViewHeightChanged?(self.containerView!.frame.size.height)
    }

    func showError(text: String) {
        self.isInErrorState = true
    }

    func hideError() {
        self.isInErrorState = false
    }
}

extension SecurityCodeRequestBaseViewController: InputDialogDelegate {
    func dismissDialog() {
        self.dismissView()
    }
    
    func displayError(errorMessage: String) {
        self.showError(text: errorMessage)
    }
}

extension SecurityCodeRequestBaseViewController: KeyboardVisibilityDelegate {
    @objc func onKeyboardWillShowOrHide(_ notification: Notification) {
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
}
