//
//  Security.swift
//  Decred Wallet
//
// Copyright (c) 2020 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

enum SecurityType: String {
    case password = "PASSWORD"
    case pin = "PIN"
}

class Security: NSObject {
    enum `Type` { // todo rename, can't have Security.Type and SecurityType
        case Startup
        case Spending
    }
    
    class Request {
        var `for`: String = "" // expects "Spending", "Startup" or other security section, todo prolly rename
        var prompt: String?
        var requestConfirmation = false
        var showCancelButton = true
        var submitBtnText: String?
    }
    
    class RequestCallbacks {
        var onViewHeightChanged: ((_ height: CGFloat) -> Void)?
        var onLoadingStatusChanged: ((_ loading: Bool) -> Void)?
        var onSecurityCodeEntered: SecurityCodeRequestCallback?
    }
    
    private var type: Type
    private var request = Request()
    private var callbacks = RequestCallbacks()
    private var currentSecurityType: String?
    
    static func startup() -> Security {
        return Security(type: .Startup)
    }
    
    static func spending() -> Security {
        return Security(type: .Spending)
    }
    
    private init(type: Type) {
        self.type = type
        super.init()
        
        if self.type == .Startup {
            self.setDefaultStartupSecurityRequestParameters()
        } else {
            self.setDefaultSpendingSecurityRequestParameters()
        }
    }
    
    private func setDefaultStartupSecurityRequestParameters() {
        self.currentSecurityType = StartupPinOrPassword.currentSecurityType()
        self.request.for = LocalizedStrings.startup
        
        if self.currentSecurityType == SecurityType.password.rawValue {
            self.request.prompt = LocalizedStrings.promptStartupPassword
        } else {
            self.request.prompt = LocalizedStrings.promptStartupPIN
        }
    }
    
    private func setDefaultSpendingSecurityRequestParameters() {
        self.currentSecurityType = SpendingPinOrPassword.currentSecurityType()
        self.request.for = LocalizedStrings.spending
        
        if self.currentSecurityType == SecurityType.password.rawValue {
            self.request.prompt = LocalizedStrings.enterCurrentSpendingPassword
        } else {
            self.request.prompt = LocalizedStrings.enterCurrentSpendingPIN
        }
    }
    
    @discardableResult
    func `for`(_ securityFor: String) -> Security {
        self.request.for = securityFor
        return self
    }
    
    @discardableResult
    func with(prompt: String) -> Security {
        self.request.prompt = prompt
        return self
    }
    
    @discardableResult
    func should(requestConfirmation: Bool) -> Security {
        self.request.requestConfirmation = requestConfirmation
        return self
    }
    
    @discardableResult
    func should(showCancelButton: Bool) -> Security {
        self.request.showCancelButton = showCancelButton
        return self
    }
    
    @discardableResult
    func with(submitBtnText: String) -> Security {
        self.request.submitBtnText = submitBtnText
        return self
    }
    
    @discardableResult
    func on(viewHeightChanged onViewHeightChanged: @escaping (_ height: CGFloat) -> Void) -> Security {
        self.callbacks.onViewHeightChanged = onViewHeightChanged
        return self
    }
    
    @discardableResult
    func on(loadingStatusChanged onLoadingStatusChanged: @escaping (_ loading: Bool) -> Void) -> Security {
        self.callbacks.onLoadingStatusChanged = onLoadingStatusChanged
        return self
    }
    
    func requestSecurityCode(sender vc: UIViewController,
                             callback onSecurityCodeEntered: @escaping SecurityCodeRequestCallback) {
        
        self.callbacks.onSecurityCodeEntered = onSecurityCodeEntered
        self.request(sender: vc)
    }
    
    private func request(sender vc: UIViewController) {
        var securityRequestVC: SecurityRequestBaseViewController
        if self.currentSecurityType == SecurityType.password.rawValue {
            securityRequestVC = RequestPasswordViewController.instantiate(from: .Security)
        } else {
            securityRequestVC = RequestPinViewController.instantiate(from: .Security)
        }
        securityRequestVC.request = self.request
        securityRequestVC.callbacks = self.callbacks
        securityRequestVC.modalPresentationStyle = .pageSheet
        vc.present(securityRequestVC, animated: true)
    }
}
