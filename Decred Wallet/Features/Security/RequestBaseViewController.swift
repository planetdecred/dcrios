//
//  RequestBaseViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class RequestBaseViewController: SecurityBaseViewController {
    var isInErrorState = false
    var requestConfirmation = false
    var showCancelButton = false
    var prompt: String?
    var submitBtnText: String?
    var securityFor: String = "" // expects "Spending", "Startup" or other security section
    var onUserEnteredCode: ((_ code: String, _ securityRequestVC: RequestBaseViewController?) -> Void)?
    
    func showError(text: String) {
        self.isInErrorState = true
    }
    
    func hideError() {
        self.isInErrorState = false
    }
}
