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
    var isInErrorState = false
    var requestConfirmation = false
    var showCancelButton = false
    var prompt: String?
    var submitBtnText: String?
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var onUserEnteredSecurityCode: ((_ code: String, _ completionDelegate: SecurityRequestCompletionDelegate?) -> Void)?

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
